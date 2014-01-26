
Shader "Alloy/Effects/MaskedIncandescence Rim" {
Properties {
	_RimTint            	("Rim Tint", Color)                 	= (1,1,1,1)
	_RimIntensity       	("Rim Intensity", Float)            	= 0 
	_RimPower           	("Rim Power", Float)                	= 4

	_IncandescenceMaskScale ("Incandescence Mask Scale", Range(0,1))= 1.0
    _IncandescenceMask  	("Incandescence Mask (A)", 2D)          = "white" {}
    _IncandescenceTint  	("Incandescence Tint", Color)       	= (1,1,1,1)
    _IncandescenceScale 	("Incandescence Intensity", Float)  	= 0
    _IncandescenceMap   	("Incandescence (RGB)", 2D)         	= "white" {}
}
    
SubShader { 
    Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
    LOD 500
    
    Zwrite Off
    Blend One One
    
CGPROGRAM
    #pragma surface surf Lambert
	           
  	#include "AlloyUtils.cginc"
	                  	                         	                         	                  
	struct Input {
	    float2 uv_IncandescenceMask;
	    float2 uv2_IncandescenceMap;  
	    float3 viewDir;
	};
        
	float4 _RimTint;
	float _RimIntensity;
	float _RimPower;
	
	float4 _IncandescenceTint;
	float _IncandescenceScale;
	float _IncandescenceMaskScale;
	sampler2D _IncandescenceMap;
	sampler2D _IncandescenceMask;
			
	void surf (Input IN, inout SurfaceOutput o) {    
	    half3 incandescence = AlloyDeGamma(_IncandescenceScale) * _IncandescenceTint.rgb * tex2D(_IncandescenceMap, IN.uv2_IncandescenceMap).rgb;
		half dotNE = saturate(dot(o.Normal, normalize(IN.viewDir)));
    	half mask =  _IncandescenceMaskScale * tex2D(_IncandescenceMask, IN.uv_IncandescenceMask).a;
    	
	    o.Emission  = incandescence * mask;
    	o.Emission += AlloyRimLight(_RimTint.rgb, AlloyDeGamma(_RimIntensity), _RimPower, dotNE);
	}
ENDCG
}
    
Fallback "Bumped Specular"
}