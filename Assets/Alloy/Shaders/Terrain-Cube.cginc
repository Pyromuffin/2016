
#ifndef TERRAIN_CUBE_CGINC
#define TERRAIN_CUBE_CGINC

#include "Alloy.cginc"

struct Input {
	float2 uv_Control;
	float2 uv_Splat0;
	float2 uv_Splat1;
	float2 uv_Splat2;
	float2 uv_Splat3;
	float3 viewDir;
    float3 worldRefl;
    float3 worldNormal;
    INTERNAL_DATA
};

void vert (inout appdata_full v) {
	v.tangent.xyz = cross(v.normal, float3(0,0,1));
	v.tangent.w = -1;// IMPORTANT: Keep so console doesn't complain.
}

float4 _BaseTint1;
float _Metallic1;
float _Smoothness1;
float4 _BaseTint2;
float _Metallic2;
float _Smoothness2;
float4 _BaseTint3;
float _Metallic3;
float _Smoothness3;
float4 _BaseTint4;
float _Metallic4;
float _Smoothness4;
sampler2D _Control;
sampler2D _Splat0,_Splat1,_Splat2,_Splat3;
sampler2D _Normal0,_Normal1,_Normal2,_Normal3;
sampler2D _Rsrm;
samplerCUBE _EnvMap;

void surf (Input IN, inout AlloySurfaceOutput o) {
    // Setup
		AlloySurfaceDescription desc = (AlloySurfaceDescription)0;
		AlloyInitializeSurfaceDescription(desc);
	
	// Inputs
    half4 splat_control = tex2D (_Control, IN.uv_Control);
	half4 base1 = splat_control.r * tex2D (_Splat0, IN.uv_Splat0);
	half4 base2 = splat_control.g * tex2D (_Splat1, IN.uv_Splat1);
	half4 base3 = splat_control.b * tex2D (_Splat2, IN.uv_Splat2);
	half4 base4 = splat_control.a * tex2D (_Splat3, IN.uv_Splat3);
	
	half4 base = 
		(base1 * half4(_BaseTint1.rgb, _Smoothness1))
		+ (base2 * half4(_BaseTint2.rgb, _Smoothness2))
		+ (base3 * half4(_BaseTint3.rgb, _Smoothness3))
		+ (base4 * half4(_BaseTint4.rgb, _Smoothness4));
					
	half metalness = 
		(splat_control.r * _Metallic1)
		+ (splat_control.g * _Metallic2)
		+ (splat_control.b * _Metallic3)
		+ (splat_control.a * _Metallic4);
				                        
	fixed4 nrm;
	nrm  = splat_control.r * tex2D (_Normal0, IN.uv_Splat0);
	nrm += splat_control.g * tex2D (_Normal1, IN.uv_Splat1);
	nrm += splat_control.b * tex2D (_Normal2, IN.uv_Splat2);
	nrm += splat_control.a * tex2D (_Normal3, IN.uv_Splat3);
	// Sum of our four splat weights might not sum up to 1, in
	// case of more than 4 total splat maps. Need to lerp towards
	// "flat normal" in that case.
	fixed splatSum = dot(splat_control, fixed4(1,1,1,1));
	fixed4 flatNormal = fixed4(0.5,0.5,1,0.5); // this is "flat normal" in both DXT5nm and xyz*2-1 cases
	nrm = lerp(flatNormal, nrm, splatSum);
    half3 normal = UnpackNormal(nrm);
		
	// Shared Data
	desc.DotNE 			= saturate(dot(normalize(IN.viewDir), normal)); 
	desc.WorldNormal 	= normalize((half3)WorldNormalVector(IN, normal));
	desc.WorldReflection = normalize((half3)WorldReflectionVector(IN, normal));
	
	// Material Data
	desc.Alpha		= 1.0h;
	desc.BaseColor	= base.rgb;
	desc.Metalness	= metalness;
	desc.Smoothness	= base.a;
	desc.Occlusion	= 1.0h;
	desc.Normal		= normal;
	desc.Emission 	= 0.0h;

	// Final Output
	AlloySurface(desc, _Rsrm, _EnvMap, o);
}

#endif // TERRAIN_CUBE_CGINC