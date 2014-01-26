
Shader "Alloy/Self-Illumin/Cutout Hdr" {
Properties {
	_Cutoff 			("Alpha cutoff", Range(0,1)) 				= 0.5
	
	_EmissionTint 		("Emission Tint", Color) 					= (1,1,1,1)
	_EmissionIntensity 	("Emission Intensity", Float)  				= 0
	_EmissionLM 		("Emission (Lightmapper)", Float) 			= 0
    _Color 				("Main Color", Color) 						= (1,1,1,1)
	_MainTex 			("Base (RGB)", 2D) 							= "white" {}
}
     
SubShader { 
	Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
	LOD 300
    
CGPROGRAM
    #pragma surface surf Lambert alphatest:_Cutoff
	
	#include "AlloyUtils.cginc"
	
    struct Input {
    	float2 uv_MainTex;
    };
    
    float4 _Color; 
    sampler2D _MainTex; 
	sampler2D _Illum;
	float4 _EmissionTint;
	float _EmissionIntensity;

    void surf (Input IN, inout SurfaceOutput o) { 
	    half4 base = _Color * tex2D(_MainTex, IN.uv_MainTex);
	    
	    o.Alpha 	= base.a;
	    o.Albedo 	= base.rgb;
	    o.Emission  = AlloyDeGamma(_EmissionIntensity) * _EmissionTint * base.rgb;
    }
ENDCG
}
    
Fallback "Self-Illumin/Diffuse"
}