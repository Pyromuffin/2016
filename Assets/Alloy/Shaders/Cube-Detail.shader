
Shader "Alloy/Core/Cube Detail" {
Properties {
	_Color 				("Main Color", Color) 						= (1,1,1,1)
	_MainTex 			("Base (RGB)", 2D) 							= "white" {}
	_Metallic 			("Metalness", Range(0,1))    				= 1.0
	_Smoothness 		("Smoothness", Range(0,1))    				= 1.0
	_ReflectanceMap 	("Metalness (R) Smoothness (A)", 2D) 		= "white" {}
    _AoMap              ("Ambient Occlusion (G)", 2D)       		= "white" {}
	_BumpMap            ("Normalmap", 2D)                   		= "bump" {}
    
    _Detail    			("Detail (RGB)", 2D)           				= "white" {}
    _DetailAoMap 		("Detail Ambient Occlusion (G)", 2D)   		= "white" {}
    _DetailIntensity	("Detail Intensity", Range(0,1))			= 1.0
    _DetailBumpMap      ("Detail Normalmap", 2D)             		= "bump" {}

    _Rsrm               ("Radially-Symmetric Reflection Map", 2D)	= "black" {}
    _EnvMap             ("Reflection Cube Map", CUBE)       		= "black" {}
}
    
SubShader { 
    Tags { "RenderType" = "Opaque" }
    LOD 250
    
CGPROGRAM
    #pragma surface surf AlloyBrdf noambient novertexlights
    #pragma target 3.0
	
	#include "Alloy.cginc"
	                  
	struct Input {
	    float2 uv_MainTex; 
	    float2 uv_Detail; 
	    float3 viewDir;
	    float3 worldRefl;
	    float3 worldNormal;
	    INTERNAL_DATA
	};
        
	float4 _Color;
	sampler2D _MainTex;
	float _Metallic;
	float _Smoothness;
	sampler2D _ReflectanceMap;
	sampler2D _AoMap;
	sampler2D _BumpMap;
	
	sampler2D _Detail; 
	sampler2D _DetailAoMap;
	float _DetailIntensity;
	sampler2D _DetailBumpMap;
	
	sampler2D _Rsrm;
	samplerCUBE _EnvMap;
		
	void surf (Input IN, inout AlloySurfaceOutput o) {   
	    // Setup
		AlloySurfaceDescription desc = (AlloySurfaceDescription)0;
		AlloyInitializeSurfaceDescription(desc);
		
		// Inputs
	    half4 base = _Color * tex2D(_MainTex, IN.uv_MainTex);
	    base *= tex2D(_Detail, IN.uv_Detail);
	    
	    half4 reflectance = tex2D(_ReflectanceMap, IN.uv_MainTex);
	    
	    half occlusion = tex2D(_AoMap, IN.uv_MainTex).g;
	    occlusion *= tex2D(_DetailAoMap, IN.uv_Detail).g;
	    
	    half3 normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
	    half3 detailNormal = normal;
	    detailNormal.xy += UnpackNormal(tex2D(_DetailBumpMap, IN.uv_Detail)).xy;
	    detailNormal = normalize(detailNormal);
		normal = lerp(normal, detailNormal, _DetailIntensity);
		
		// Shared Data
		desc.DotNE 			= saturate(dot(normalize(IN.viewDir), normal)); 
    	desc.WorldNormal 	= normalize((half3)WorldNormalVector(IN, normal));
    	desc.WorldReflection = normalize((half3)WorldReflectionVector(IN, normal));
    	
		// Material Data
		desc.BaseColor	= base.rgb;
		desc.Metalness	= _Metallic * reflectance.r;
		desc.Smoothness	= _Smoothness * reflectance.a;
		desc.Occlusion	= occlusion;
		desc.Normal		= normal;
	
    	// Final Output
		AlloySurface(desc, _Rsrm, _EnvMap, o);
	}
ENDCG
}
    
Fallback "Bumped Diffuse"
}