
Shader "Alloy/Transparent/Rsrm" {
Properties {
	_Color 				("Main Color", Color) 						= (1,1,1,1)
	_MainTex 			("Base (RGB) Trans (A)", 2D) 				= "white" {}
	_Metallic 			("Metalness", Range(0,1))    				= 1.0
	_Smoothness 		("Smoothness", Range(0,1))    				= 1.0
	_ReflectanceMap 	("Metalness (R) Smoothness (A)", 2D) 		= "white" {}
    _AoMap              ("Ambient Occlusion (G)", 2D)       		= "white" {}
	_BumpMap            ("Normalmap", 2D)                   		= "bump" {}
	
    _Rsrm               ("Radially-Symmetric Reflection Map", 2D)	= "black" {}
}
    
SubShader { 
	Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
	LOD 400
    
    Zwrite Off
    Blend One OneMinusSrcAlpha
    
CGPROGRAM
    #pragma surface surf AlloyBrdf noambient novertexlights
    #pragma target 3.0
	
	#define ALLOY_USE_TRANSLUCENCY
	#include "Alloy.cginc"
	                  
	struct Input {
	    float2 uv_MainTex; 
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
	
	sampler2D _Rsrm;
		
	void surf (Input IN, inout AlloySurfaceOutput o) {       
		// Setup
		AlloySurfaceDescription desc = (AlloySurfaceDescription)0;
		AlloyInitializeSurfaceDescription(desc);
		
		// Inputs
	    half4 base = _Color * tex2D(_MainTex, IN.uv_MainTex);
	    half4 reflectance = tex2D(_ReflectanceMap, IN.uv_MainTex);
	    half occlusion = tex2D(_AoMap, IN.uv_MainTex).g;
	    half3 normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
		
		// Shared Data
		desc.DotNE 			= saturate(dot(normalize(IN.viewDir), normal)); 
    	desc.WorldNormal 	= normalize((half3)WorldNormalVector(IN, normal));
    	desc.WorldReflection = normalize((half3)WorldReflectionVector(IN, normal));
    	
		// Material Data
		desc.Alpha		= base.a;
		desc.BaseColor	= base.rgb;
		desc.Metalness	= _Metallic * reflectance.r;
		desc.Smoothness	= _Smoothness * reflectance.a;
		desc.Occlusion	= occlusion;
		desc.Normal		= normal;
		
		// Final Output
		AlloySurface(desc, _Rsrm, o);
	}
ENDCG
}
    
FallBack "Transparent/Bumped Diffuse"
}