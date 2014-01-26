
Shader "Alloy/Transparent/Rsrm Distort MaskedIncandescence Rim" {
Properties {
	_RimTint            ("Rim Tint", Color)                 		= (1,1,1,1)
	_RimIntensity       ("Rim Intensity", Float)            		= 0 
	_RimPower           ("Rim Power", Float)                		= 4
	
	_BumpAmt  			("Distortion", range (0,128)) 				= 10
		
	_Color 				("Main Color", Color) 						= (1,1,1,1)
	_MainTex 			("Base (RGB) Trans (A)", 2D) 				= "white" {}
	_Metallic 			("Metalness", Range(0,1))    				= 1.0
	_Smoothness 		("Smoothness", Range(0,1))    				= 1.0
	_ReflectanceMap 	("Metalness (R) Smoothness (A)", 2D)			= "white" {}
    _AoMap              ("Ambient Occlusion (G)", 2D)       		= "white" {}
	_BumpMap            ("Normalmap", 2D)                   		= "bump" {}
    	
	_IncandescenceMaskScale ("Incandescence Mask Scale", Range(0,1))= 1.0
    _IncandescenceMask  	("Incandescence Mask (A)", 2D)          = "white" {}
    _IncandescenceTint  	("Incandescence Tint", Color)       	= (1,1,1,1)
    _IncandescenceScale 	("Incandescence Intensity", Float)  	= 0
    _IncandescenceMap   	("Incandescence (RGB)", 2D)         	= "white" {}
	
    _Rsrm               ("Radially-Symmetric Reflection Map", 2D)	= "black" {}
}
    
SubShader {
    // We must be transparent, so other objects are drawn before this one.
	Tags { "Queue"="Transparent" "RenderType"="Opaque" }
    LOD 500

	// This pass grabs the screen behind the object into a texture.
	// We can access the result in the next pass as _GrabTexture
	GrabPass {							
		Name "BASE"
		Tags { "LightMode" = "Always" }
	}
	 
	// Main pass: Take the texture grabbed above and use the bumpmap to perturb it
	// on to the screen
	Pass {
		Name "BASE"
		Tags { "LightMode" = "Always" }
			
CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#pragma fragmentoption ARB_precision_hint_fastest
	#include "UnityCG.cginc"
	
	struct appdata_t {
		float4 vertex : POSITION;
		float2 texcoord: TEXCOORD0;
	};
	
	struct v2f {
		float4 vertex : POSITION;
		float4 uvgrab : TEXCOORD0;
		float2 uvbump : TEXCOORD1;
		float2 uvmain : TEXCOORD2;
	};
	
	float _BumpAmt;
	float4 _BumpMap_ST;
	float4 _MainTex_ST;
	
	v2f vert (appdata_t v)
	{
		v2f o;
		o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
		#if UNITY_UV_STARTS_AT_TOP
		float scale = -1.0;
		#else
		float scale = 1.0;
		#endif
		o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y*scale) + o.vertex.w) * 0.5;
		o.uvgrab.zw = o.vertex.zw;
		o.uvbump = TRANSFORM_TEX( v.texcoord, _MainTex );
		o.uvmain = TRANSFORM_TEX( v.texcoord, _MainTex );
		return o;
	}
		
	float4 _Color;
	sampler2D _GrabTexture;
	float4 _GrabTexture_TexelSize;
	sampler2D _BumpMap;
	sampler2D _MainTex;
	
	half4 frag( v2f i ) : COLOR
	{
		// calculate perturbed coordinates
		half2 bump = UnpackNormal(tex2D( _BumpMap, i.uvbump )).rg; // we could optimize this by just reading the x & y without reconstructing the Z
		float2 offset = bump * _BumpAmt * _GrabTexture_TexelSize.xy;
		i.uvgrab.xy = offset * i.uvgrab.z + i.uvgrab.xy;
		
		half4 col = tex2Dproj( _GrabTexture, UNITY_PROJ_COORD(i.uvgrab));
		half4 base = tex2D( _MainTex, i.uvmain ) * _Color;
		return col * base;
	}
ENDCG
	}
	
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
    LOD 500
    
    Zwrite Off
    Blend One OneMinusSrcAlpha
    
CGPROGRAM
    #pragma surface surf AlloyBrdf noambient novertexlights
    #pragma target 3.0
	
	#define ALLOY_USE_TRANSLUCENCY
	#include "Alloy.cginc"
	                  
	struct Input {
	    float2 uv_MainTex; 
	    float2 uv2_IncandescenceMap; 
	    float3 viewDir;
	    float3 worldRefl;
	    float3 worldNormal;
	    INTERNAL_DATA
	};
    
	float4 _RimTint;
	float _RimIntensity;
	float _RimPower;
        
	float4 _Color;
	sampler2D _MainTex;
	sampler2D _ReflectanceMap;
	float _Metallic;
	float _Smoothness;
	sampler2D _BumpMap;
	sampler2D _AoMap;
	
	float4 _IncandescenceTint;
	float _IncandescenceScale;
	sampler2D _IncandescenceMap;
	float _IncandescenceMaskScale;
	sampler2D _IncandescenceMask;
	
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
	    
	    half3 incandescence = AlloyDeGamma(_IncandescenceScale) * _IncandescenceTint.rgb * tex2D(_IncandescenceMap, IN.uv2_IncandescenceMap).rgb;
    	incandescence *= _IncandescenceMaskScale * tex2D(_IncandescenceMask, IN.uv_MainTex).a;
		
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
		desc.Emission 	= incandescence;
    	desc.Emission 	+= AlloyRimLight(_RimTint.rgb, AlloyDeGamma(_RimIntensity), _RimPower, desc.DotNE);
		
    	// Final Output
		AlloySurface(desc, _Rsrm, o);
	}
ENDCG
}
    
FallBack "Transparent/Bumped Diffuse"
}