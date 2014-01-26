
/////////////////////////////////////////////////////////////////////////////////
/// @file AlloyCore.cginc
/// @brief Alloy's material system's core functions and data structures.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_CORE_CGINC
#define ALLOY_CORE_CGINC

#include "AlloyUtils.cginc"

/// Maximum monochrome f0 in linear space to remap the range of values [0,1].
#define ALLOY_MAX_BASE_F0 0.08h

/// World-space normalized up vector.
#define ALLOY_WORLD_UP_DIRECTION half3(0.0h, 1.0h, 0.0h)

// Spherical Gaussian approximation constants.
// http://seblagarde.wordpress.com/2011/08/17/hello-world/#more-1
#define ALLOY_LOG2_OF1_ON_LN2_PLUS2 2.528766
#define ALLOY_LN2_MUL2_DIV8 0.173287

/// Used to pass material data to Unity's lighting functions. 
/// The surface shader should never modify this directly.
struct AlloySurfaceOutput {
	// NOTE: Single component fields arranged at the top so that Unity will pack
	// them. Otherwise it would not compile for certain cases.
	
	/// Controls translucency or cutout regions.
	/// Expects values in the range [0,1].
	half Alpha;
	
	/// Smoothness value.
	/// Had to use reserved name to pass to deferred lighting shader. Expects 
	/// values in the range [0,1].
	half Specular;
	
	/// Ambient occlusion or cavity data.
	/// This is only applied to the ambient lighting, and does not affect 
	/// illumination from direct light sources. Expects values in the range [0,1].
	half Occlusion;
	
	/// Diffuse albedo.
	/// Expects linear-space LDR color values.
	half3 Albedo;
	
	/// Tangent space normal.
	/// Expects normalized vectors in the range [-1,1].
	half3 Normal;
	
	/// "Light" emitted by the surface. Used for custom ambient lighting.
	/// Expects linear-space HDR color values.
	half3 Emission;
	
	/// Fresnel at incidence angle zero. 
	/// Expects linear-space LDR color values.
	half3 F0;
	
	/// Used to pass environment map specular data to lightmap functions.
	/// Don't mess with this one directly! Expects linear-space HDR color values.
	half3 EnvMap;
};

/// Used to collect material data in shader's surface callback.
struct AlloySurfaceDescription {
	/// Dot product of the normal and the eye vector.
	/// Needed for fresnel and rimlight calculations. Expects values in the 
	/// range [0,1].
	half DotNE;
	
	/// World-space normal.
	/// Needed for ambient diffuse calculations. Expects normalized vectors in 
	/// the range [-1,1].
	half3 WorldNormal;
	
	/// World-space normalized eye reflection vector.
	/// Needed for ambient specular calculations. Expects normalized vectors in 
	/// the range [-1,1].
	half3 WorldReflection;
	
	/// Controls translucency or cutout regions.
	/// Expects values in the range [0,1].
	half Alpha;
	
	/// Used to populate the material's Albedo or F0 based on the metalness 
	/// parameter. Expects linear-space LDR color values.
	half3 BaseColor;
	
	/// Blends the material between a dielectric substance and a metallic 
	/// substance, where higher values are more metallic. Expects values in the 
	/// range [0,1].
	half Metalness;
	
	/// Controls apparent smoothness of reflections and lighting, where higher 
	/// values are smoother. Expects values in the range [0,1].
	half Smoothness;
	
	/// Controls f0 for low metalness materials.
	/// Expects values in the range [0,1].
	half Specularity;
	
	/// Ambient occlusion or cavity data.
	/// This is only applied to the ambient lighting, and does not affect 
	/// illumination from direct light sources. Expects values in the range [0,1].
	half Occlusion;
	
	/// Tangent space normal.
	/// Expects normalized vectors in the range [-1,1].
	half3 Normal;
	
	/// "Light" emitted by the surface.
	/// Expects linear-space HDR color values.
	half3 Emission;
};


/////////////////////////////////////////////////////////////////////////////////
// Internal Methods
/////////////////////////////////////////////////////////////////////////////////

/// Per-light fresnel.
/// @param f0		Fresnel at incidence angle zero. 
/// @param dotHL	Dot product of the light and half angle vectors.
half3 AlloyFresnel(half3 f0, half dotHL) {
#ifdef ALLOY_USE_FRESNEL_SPHERICAL_GAUSSIAN_APPROXIMATION
	// Schlick Fresnel with spherical gaussian and fresnel attenuation approximations
	// as proposed by:
	// http://seblagarde.wordpress.com/2011/08/17/hello-world/#more-1
	return f0 + (1.0h - f0) * exp2((-5.55473 * dotHL - 6.98316) * dotHL);
#else
  	return f0 + (1.0h - f0) * pow(1.0h - dotHL, 5.0h);
#endif
}

/// Environment map fresnel with a visibility approximation.
/// @param f0			Fresnel at incidence angle zero. 
/// @param smoothness	Smoothness value for the surface.
/// @param dotNE		Dot product of the normal and eye vectors.
half3 AlloyFresnelWithVisibility(half3 f0, half smoothness, half dotNE) {
#ifdef ALLOY_USE_FRESNEL_SPHERICAL_GAUSSIAN_APPROXIMATION
	// Schlick Fresnel with spherical gaussian and fresnel attenuation approximations
	// as proposed by:
	// http://seblagarde.wordpress.com/2011/08/17/hello-world/#more-1
	return f0 + (max(smoothness.rrr, f0) - f0) * exp2((-5.55473 * dotNE - 6.98316) * dotNE);
#else
  	return f0 + (max(smoothness.rrr, f0) - f0) * pow(1.0h - dotNE, 5.0h);
#endif
}

/// Initializes ambient specular data, and applies light probe if needed.
/// @param[in]		envMap			Environment map contribution.
/// @param[in]		worldNormal		World-space normal.
/// @param[in]		worldReflection	World-space normalized eye reflection vector.
/// @param[in]		dotNE			Dot product of the normal and eye vectors.
/// @param[in,out]	o				Surface with lighting information applied.
void AlloyApplyAmbient(half3 envMap, half3 worldNormal, half3 worldReflection, half dotNE, inout AlloySurfaceOutput o) {
	// Store value for use in either light probe or lightmap pass.
	// Only apply dotNE fresnel to EnvMap.
	o.EnvMap = envMap * AlloyFresnelWithVisibility(o.F0, o.Specular, dotNE);
	
#if defined(LIGHTMAP_OFF) || defined(DIRLIGHTMAP_OFF)
    // Ambient Lighting 
    // Needs 2.0 to be in the range Unity expects.
    o.Emission += (o.Occlusion * 2.0h) * (
            	ShadeSH9(float4(worldNormal, 1.0f)) * o.Albedo +
            	ShadeSH9(float4(worldReflection, 1.0f)) * o.EnvMap);
#endif
}

/// Builds the Blinn Phong normalization factor from surface smoothness.
/// This is useful in the context of a Light PrePass renderer with a
/// low-precision light accumulation buffer, since it moves the HDR component
/// to the combine pass.
/// @param 	smoothness 	Surface smoothness.
/// @return				Blinn Phong distribution normalization factor.
half AlloyBlinnPhongNormalizationWithVisibility(half smoothness) {
	// Combines FarCry 3's (2sp + 1) / 8 normalization + visibility 
	// approximation with a 4x specular power to make Blinn Phong's 
	// highlights consistent with Phong IBL.
	half sp = exp2(smoothness * 8.0h + 2.0h); // [4,1024]
	return (sp * 0.25h + 0.125h); // (2sp + 1) / 8
}

/// Builds the Blinn Phong BRDF.
/// This is useful in the context of a Light PrePass renderer with a
/// low-precision light accumulation buffer, since it moves the HDR component
/// out of the lighting pass.
/// @param 	dotNH 		Dot product of the normal with the half-angle vector.
/// @param 	smoothness 	Surface smoothness.
/// @return				Blinn Phong distribution without normalization.
half AlloyBlinnPhong(half dotNH, half smoothness) {
#ifdef ALLOY_USE_BLINN_PHONG_SPHERICAL_GAUSSIAN_APPROXIMATION
	half sp = exp2(smoothness * 8.0h + ALLOY_LOG2_OF1_ON_LN2_PLUS2);
	return exp2(sp * dotNH - sp);
#else
	half sp = exp2(smoothness * 8.0h + 2.0h); // [4,1024]
	return pow(dotNH, sp); // (2sp + 1) / 8
#endif
}

/// Builds the Normalized Blinn Phong BRDF with a visibility approximation.
/// @param 	dotNH 		Dot product of the normal with the half-angle vector.
/// @param 	smoothness 	Surface smoothness.
/// @return				Normalized Blinn Phong distribution.
half AlloyNormalizedBlinnPhongWithVisibility(half dotNH, half smoothness) {
	// Combines FarCry 3's (2sp + 1) / 8 normalization + visibility 
	// approximation with a 4x specular power to make Blinn Phong's 
	// highlights consistent with Phong IBL.
#ifdef ALLOY_USE_BLINN_PHONG_SPHERICAL_GAUSSIAN_APPROXIMATION
	// Spherical gaussian approximation to Blinn Phong.
	half sp = exp2(smoothness * 8.0h + ALLOY_LOG2_OF1_ON_LN2_PLUS2);
	return (sp * ALLOY_LN2_MUL2_DIV8 + 0.125h) * exp2(sp * dotNH - sp);
#else
	half sp = exp2(smoothness * 8.0h + 2.0h); // [4,1024]
	return (sp * 0.25h + 0.125h) * pow(dotNH, sp); // (2sp + 1) / 8
#endif
}

/// Takes in material data and outputs energy conserving BRDF parameters. 
/// @param[in]		desc	Material surface description.
/// @param[in,out]	o		Material output for Unity lighting system.
void AlloyConvertSurfaceDescriptionToOutput(AlloySurfaceDescription desc, inout AlloySurfaceOutput o) {
	half3 baseColor = desc.BaseColor;
	half metalness = desc.Metalness;
	half baseF0 = desc.Specularity * ALLOY_MAX_BASE_F0;
	 
	o.Occlusion = desc.Occlusion;
	o.Alpha 	= desc.Alpha;
	o.Albedo    = baseColor * (1.0h - metalness);
	o.Normal    = desc.Normal;  
	o.F0		= lerp(baseF0.rrr, baseColor, metalness);
	o.Specular  = desc.Smoothness;
	o.Emission  = desc.Emission;
	
	// Approximation to preserve diffuse + refraction + reflection <= 1.
	half lumF0 = AlloyLinearLuminance(o.F0);
	half invLumF0 = (1.0h - lumF0);
	
	// Ensures that alpha only affects albedo for translucent shaders.
	// This way, cutout shaders won't have any visual oddities.
#ifdef ALLOY_USE_TRANSLUCENCY
	half invLumF0Alpha = invLumF0 * o.Alpha;
	
	// Alpha gets higher as f0 gets higher, until f0 overpowers alpha.
	o.Alpha = lumF0 + invLumF0Alpha;
	
	// Albedo loses energy as alpha and/or f0 gets higher.
	o.Albedo *= invLumF0Alpha;
#else
	// Albedo loses energy as f0 gets higher.
	o.Albedo *= invLumF0; 
#endif
}


/////////////////////////////////////////////////////////////////////////////////
// Surface Shader Methods
/////////////////////////////////////////////////////////////////////////////////

/// Combines two surface descriptions by blending one on top of the other.
/// @param[in]		weight	Controls how much temp blends on top of desc.
/// @param[in]		temp 	Input material data that gets blended on top of desc.
/// @param[in,out] 	desc 	Material data accumulator.
void AlloyInterpolateMaterial(half weight, AlloySurfaceDescription temp, inout AlloySurfaceDescription desc) {
	desc.Alpha		= lerp(desc.Alpha, temp.Alpha, weight);
	desc.BaseColor	= lerp(desc.BaseColor, temp.BaseColor, weight);
	desc.Metalness	= lerp(desc.Metalness, temp.Metalness, weight);
	desc.Smoothness	= lerp(desc.Smoothness, temp.Smoothness, weight);
	desc.Specularity= lerp(desc.Specularity, temp.Specularity, weight);
	desc.Occlusion	= lerp(desc.Occlusion, temp.Occlusion, weight);
	desc.Normal 	= lerp(desc.Normal, temp.Normal, weight);
	desc.Emission 	= lerp(desc.Emission, temp.Emission, weight);
}

/// Populates a surface description's fields with sane default values.
/// This should ALWAYS be the first call of an Alloy surface shader.
/// @param[out] desc Surface description to be initialized.
void AlloyInitializeSurfaceDescription(out AlloySurfaceDescription desc) {
	desc.DotNE			= 0.0h;
	desc.WorldNormal 	= 1.0h; // They need to overwrite this one!
	desc.WorldReflection = 1.0h; // They need to overwrite this one!

	desc.Alpha		= 1.0h;
	desc.BaseColor	= 0.0h;
	desc.Metalness	= 0.0h;
	desc.Smoothness	= 0.0h;
	desc.Specularity= 0.5h; // Will put the amount at 0.04 when converted.
	desc.Occlusion	= 1.0h;
	desc.Normal 	= 1.0h; // They need to overwrite this one!
	desc.Emission 	= 0.0h;
}

/// Converts a surface description to the format expected by the lighting system.
/// This should ALWAYS be the final call of an Alloy surface shader.
/// @param[in] 		desc	Surface description with material data.
/// @param[in] 		rsrm	A 2D texture Radially Symmetric Reflection Map.
/// @param[in,out] 	o		Surface output data in the format that Unity expects.
void AlloySurface (AlloySurfaceDescription desc, sampler2D rsrm, inout AlloySurfaceOutput o) {
	AlloyConvertSurfaceDescriptionToOutput(desc, o);
  
    half3 worldNormal = desc.WorldNormal;
    half3 worldReflection = desc.WorldReflection;
    half dotRU = dot(worldReflection, ALLOY_WORLD_UP_DIRECTION) * 0.5h + 0.5h;
    half3 envMap = tex2D(rsrm, float2(dotRU, o.Specular)).rgb;
	
	AlloyApplyAmbient(envMap, worldNormal, worldReflection, desc.DotNE, o);
}

/// Converts a surface description to be used in the lighting system.
/// This should ALWAYS be the final call of an Alloy surface shader.
/// @param[in] 		desc	Surface description with material data.
/// @param[in] 		rsrm	A 2D texture Radially Symmetric Reflection Map.
/// @param[in] 		envMap	A Cube texture environment map.
/// @param[in,out] 	o		Surface output data in the format that Unity expects.
void AlloySurface (AlloySurfaceDescription desc, sampler2D rsrm, samplerCUBE envMap, inout AlloySurfaceOutput o) {
	AlloyConvertSurfaceDescriptionToOutput(desc, o);
  
    half3 worldNormal = desc.WorldNormal;
    half3 worldReflection = desc.WorldReflection;
    half dotRU = dot(worldReflection, ALLOY_WORLD_UP_DIRECTION) * 0.5h + 0.5h;
    half glossiness = o.Specular; 
	half3 rsrmSample = tex2D(rsrm, float2(dotRU, glossiness)).rgb;
	half3 envMapSample = texCUBE(envMap, worldReflection).rgb;
	
	// HACK: Something to try to make the cube and RSRM blend more naturally.
	half interpolation = saturate(max(ALLOY_EPSILON, glossiness - 0.25h) / 0.75h);
    half3 combinedMap = lerp(rsrmSample, envMapSample, interpolation);
	
	AlloyApplyAmbient(combinedMap, worldNormal, worldReflection, desc.DotNE, o);
}

#endif // ALLOY_CORE_CGINC
