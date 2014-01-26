
/////////////////////////////////////////////////////////////////////////////////
/// @file Alloy.cginc
/// @brief Alloy's Unity lighting callback functions.
/////////////////////////////////////////////////////////////////////////////////

#ifndef ALLOY_CGINC
#define ALLOY_CGINC

#include "AlloyCore.cginc"

half4 LightingAlloyBrdf(AlloySurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
	half3 n = s.Normal; 
	half3 h = normalize(lightDir + viewDir);
	half dotNL = saturate(dot(n, lightDir));
	half dotNH = saturate(dot(n, h));
	half dotHL = saturate(dot(h, lightDir));
	half dv = AlloyNormalizedBlinnPhongWithVisibility(dotNH, s.Specular);
	half3 spec;
	half4 c;	
	
#ifdef ALLOY_USE_PER_LIGHT_FRESNEL_IN_FORWARD_MODE
  	spec = AlloyFresnel(s.F0, dotHL) * dv;
#else
	// No fresnel, to stay consistent with deferred mode.
  	spec = s.F0 * dv;
#endif
	
	// Use the punctual lighting equation to correctly attenuate specular.
	c.rgb =  _LightColor0.rgb * (2.0h * atten * dotNL) * (
				s.Albedo +
                spec);
                
	// Required in order to support alpha-blending.
    c.a = s.Alpha + (_LightColor0.a * AlloyLinearLuminance(spec) * atten); 
	return c;
}

half4 LightingAlloyBrdf_PrePass(AlloySurfaceOutput s, half4 light) {
	// Applies normalization factor here to ease precision needs of the light
	// accumulation buffer. Also ensures a better preview in the editor view
	// where a low-precision bufffer is unavoidable.
	half dv = AlloyBlinnPhongNormalizationWithVisibility(s.Specular) * light.a; 
  	half3 spec = s.F0 * dv;	
	half4 c;
	
	// Combine chromaticity of diffuse lighting with accumulated light color
	// luminance in specular to approximate missing light color.
	c.rgb = (s.Albedo * light.rgb + 
      		spec * AlloyLinearChromaticity(light.rgb));
	
	// Not really needed, but here just to be safe.
	c.a = s.Alpha + AlloyLinearLuminance(spec); 
	return c;
}

// HACK: Uses "inout" to accumulate the lighting in the SurfaceOutput.Emission
// field. Then zero out the return value to ensure nothing gets passed through
// the _PrePass callback in deferred mode. This way, we don't contaminate the
// recovered specular color, or have weird specular results.
half4 LightingAlloyBrdf_SingleLightmap (inout AlloySurfaceOutput s, fixed4 color) {
  	half3 lm = DecodeLightmap(color);
  	
	s.Emission += s.Occlusion * lm * (
				s.Albedo +
				s.EnvMap);
				
	return 0.0h;
}

half4 LightingAlloyBrdf_DualLightmap (inout AlloySurfaceOutput s, fixed4 totalColor, fixed4 indirectOnlyColor, half indirectFade) {
	half3 lm = lerp(DecodeLightmap(indirectOnlyColor), DecodeLightmap(totalColor), indirectFade);
  	
	s.Emission += s.Occlusion * lm * (
				s.Albedo +
				s.EnvMap);
				
	return 0.0h;
}

half4 LightingAlloyBrdf_DirLightmap (inout AlloySurfaceOutput s, fixed4 color, fixed4 scale, bool surfFuncWritesNormal) {
	UNITY_DIRBASIS;
	half3 scalePerBasisVector;
	half3 lm = DirLightmapDiffuse(unity_DirBasis, color, scale, s.Normal, surfFuncWritesNormal, scalePerBasisVector);
  	
	s.Emission += s.Occlusion * lm * (
				s.Albedo +
				s.EnvMap);
				
	return 0.0h;
}

#endif // ALLOY_CGINC
