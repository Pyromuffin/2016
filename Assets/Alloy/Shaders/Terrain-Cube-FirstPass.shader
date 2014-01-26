
Shader "Alloy/Nature/Terrain/Cube" {
Properties {
	_BaseTint1   			("Base Tint 1", Color) 				= (1,1,1,1)
	_Metallic1				("Metalness 1", Range(0,1)) 			= 0.0
	_Smoothness1			("Smoothness 1", Range(0,1)) 		= 1.0
	_BaseTint2   			("Base Tint 2", Color) 				= (1,1,1,1)
	_Metallic2				("Metalness 2", Range(0,1)) 			= 0.0
	_Smoothness2			("Smoothness 2", Range(0,1)) 		= 1.0
	_BaseTint3   			("Base Tint 3", Color) 				= (1,1,1,1)
	_Metallic3				("Metalness 3", Range(0,1)) 			= 0.0
	_Smoothness3			("Smoothness 3", Range(0,1)) 		= 1.0
	_BaseTint4   			("Base Tint 4", Color) 				= (1,1,1,1)
	_Metallic4				("Metalness 4", Range(0,1)) 			= 0.0
	_Smoothness4			("Smoothness 4", Range(0,1)) 		= 1.0
	
	_EnvMap             	("Reflection Cube Map", CUBE)       		= "black" {}
    _Rsrm                	("Radially-Symmetric Reflection Map", 2D)	= "black" {}
	
	// set by terrain engine
	[HideInInspector] _Control ("Control (RGBA)", 2D) = "red" {}
	[HideInInspector] _Splat3 ("Layer 3 (A)", 2D) = "white" {}
	[HideInInspector] _Splat2 ("Layer 2 (B)", 2D) = "white" {}
	[HideInInspector] _Splat1 ("Layer 1 (G)", 2D) = "white" {}
	[HideInInspector] _Splat0 ("Layer 0 (R)", 2D) = "white" {}
	[HideInInspector] _Normal3 ("Normal 3 (A)", 2D) = "bump" {}
	[HideInInspector] _Normal2 ("Normal 2 (B)", 2D) = "bump" {}
	[HideInInspector] _Normal1 ("Normal 1 (G)", 2D) = "bump" {}
	[HideInInspector] _Normal0 ("Normal 0 (R)", 2D) = "bump" {}
	// used in fallback on old cards & base map
	[HideInInspector] _MainTex ("BaseMap (RGB)", 2D) = "white" {}
	[HideInInspector] _Color ("Main Color", Color) = (1,1,1,1)
}
	
SubShader {
	Tags {
		"SplatCount" = "4"
		"Queue" = "Geometry-100"
		"RenderType" = "Opaque"
	}
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardBase" }
	
CGPROGRAM
    #pragma vertex vert_surf
	#pragma fragment frag_surf
	#pragma fragmentoption ARB_precision_hint_fastest
	#pragma multi_compile_fwdbase 
	#include "HLSLSupport.cginc"
	#include "UnityShaderVariables.cginc"
	#define UNITY_PASS_FORWARDBASE
	#include "UnityCG.cginc"
	#include "Lighting.cginc"
	#include "AutoLight.cginc"
	
	#define INTERNAL_DATA half3 TtoW0; half3 TtoW1; half3 TtoW2;
	#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.TtoW0,normal), dot(data.TtoW1,normal), dot(data.TtoW2,normal)))
	#define WorldNormalVector(data,normal) fixed3(dot(data.TtoW0,normal), dot(data.TtoW1,normal), dot(data.TtoW2,normal))
	#line 1
	#line 30

    //#pragma surface surf AlloyBrdf vertex:vert s
    #pragma target 3.0
	
	#include "Terrain-Cube.cginc"
	
#ifdef LIGHTMAP_OFF
struct v2f_surf {
  float4 pos : SV_POSITION;
  float4 pack0 : TEXCOORD0;
  float4 pack1 : TEXCOORD1;
  float2 pack2 : TEXCOORD2;
  float3 normal : TEXCOORD3;
  fixed3 lightDir : TEXCOORD4;
  fixed3 vlight : TEXCOORD5;
  float3 viewDir : TEXCOORD6;
  LIGHTING_COORDS(7,8)
};
#endif
#ifndef LIGHTMAP_OFF
struct v2f_surf {
  float4 pos : SV_POSITION;
  float4 pack0 : TEXCOORD0;
  float4 pack1 : TEXCOORD1;
  float2 pack2 : TEXCOORD2;
  float3 normal : TEXCOORD3;
  float2 lmap : TEXCOORD4;
  float3 viewDir : TEXCOORD5;
  LIGHTING_COORDS(6,7)
};
#endif
#ifndef LIGHTMAP_OFF
float4 unity_LightmapST;
#endif
float4 _Control_ST;
float4 _Splat0_ST;
float4 _Splat1_ST;
float4 _Splat2_ST;
float4 _Splat3_ST;
v2f_surf vert_surf (appdata_full v) {
  v2f_surf o;
  vert (v);
  o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _Control);
  o.pack0.zw = TRANSFORM_TEX(v.texcoord, _Splat0);
  o.pack1.xy = TRANSFORM_TEX(v.texcoord, _Splat1);
  o.pack1.zw = TRANSFORM_TEX(v.texcoord, _Splat2);
  o.pack2.xy = TRANSFORM_TEX(v.texcoord, _Splat3);
  #ifndef LIGHTMAP_OFF
  o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
  #endif
  float3 worldN = mul((float3x3)_Object2World, SCALED_NORMAL);
  TANGENT_SPACE_ROTATION; 
	o.normal = v.normal;
  float3 lightDir = mul (rotation, ObjSpaceLightDir(v.vertex));
  #ifdef LIGHTMAP_OFF
  o.lightDir = lightDir;
  #endif
  float3 viewDirForLight = mul (rotation, ObjSpaceViewDir(v.vertex));
  o.viewDir = viewDirForLight;
  #ifdef LIGHTMAP_OFF
  o.vlight = UNITY_LIGHTMODEL_AMBIENT.rgb;
  #endif // LIGHTMAP_OFF
  TRANSFER_VERTEX_TO_FRAGMENT(o);
  return o;
}
#ifndef LIGHTMAP_OFF
sampler2D unity_Lightmap;
#ifndef DIRLIGHTMAP_OFF
sampler2D unity_LightmapInd;
#endif
#endif
fixed4 frag_surf (v2f_surf IN) : COLOR {
  Input surfIN;
  surfIN.uv_Control = IN.pack0.xy;
  surfIN.uv_Splat0 = IN.pack0.zw;
  surfIN.uv_Splat1 = IN.pack1.xy;
  surfIN.uv_Splat2 = IN.pack1.zw;
  surfIN.uv_Splat3 = IN.pack2.xy;
  #ifdef UNITY_COMPILER_HLSL
  AlloySurfaceOutput o = (AlloySurfaceOutput)0;
  #else
  AlloySurfaceOutput o;
  #endif
  
  float3 worldRefl = mul ((float3x3)_Object2World, IN.viewDir);
  float4 tangent;
  tangent.xyz = cross(IN.normal, float3(0,0,1));
  tangent.w = -1;
  float3 binormal = cross( IN.normal, tangent.xyz ) * tangent.w;
  float3x3 rotation = float3x3(tangent.xyz, binormal, IN.normal);
  float4 TtoW0 = float4(mul(rotation, _Object2World[0].xyz), worldRefl.x)*unity_Scale.w;
  float4 TtoW1 = float4(mul(rotation, _Object2World[1].xyz), worldRefl.y)*unity_Scale.w;
  float4 TtoW2 = float4(mul(rotation, _Object2World[2].xyz), worldRefl.z)*unity_Scale.w;
  
  surfIN.worldRefl = float3(TtoW0.w, TtoW1.w, TtoW2.w);
  surfIN.TtoW0 = TtoW0.xyz;
  surfIN.TtoW1 = TtoW1.xyz;
  surfIN.TtoW2 = TtoW2.xyz;
  surfIN.worldNormal = 0.0;
  surfIN.viewDir = IN.viewDir;
  
  o.Albedo = 0.0;
  o.Emission = 0.0;
  o.Specular = 0.0;
  o.Alpha = 0.0;
  surf (surfIN, o);
  fixed atten = LIGHT_ATTENUATION(IN);
  fixed4 c = 0;
  #ifdef LIGHTMAP_OFF
  c = LightingAlloyBrdf (o, IN.lightDir, normalize(half3(IN.viewDir)), atten);
  #endif // LIGHTMAP_OFF
  #ifdef LIGHTMAP_OFF
  c.rgb += o.Albedo * IN.vlight;
  #endif // LIGHTMAP_OFF
  #ifndef LIGHTMAP_OFF
  #ifdef DIRLIGHTMAP_OFF
  fixed4 lmtex = tex2D(unity_Lightmap, IN.lmap.xy);
  fixed3 lm = DecodeLightmap (lmtex);
  #else
  fixed4 lmtex = tex2D(unity_Lightmap, IN.lmap.xy);
  fixed4 lmIndTex = tex2D(unity_LightmapInd, IN.lmap.xy);
  half3 lm = LightingAlloyBrdf_DirLightmap(o, lmtex, lmIndTex, 1).rgb;
  #endif
  #ifdef SHADOWS_SCREEN
  #if defined(SHADER_API_GLES) && defined(SHADER_API_MOBILE)
  c.rgb += o.Albedo * min(lm, atten*2);
  #else
  c.rgb += o.Albedo * max(min(lm,(atten*2)*lmtex.rgb), lm*atten);
  #endif
  #else // SHADOWS_SCREEN
  c.rgb += o.Albedo * lm;
  #endif // SHADOWS_SCREEN
  c.a = o.Alpha;
#endif // LIGHTMAP_OFF
  c.rgb += o.Emission;
  return c;
}
ENDCG
}
Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardAdd" }
		ZWrite Off Blend One One Fog { Color (0,0,0,0) }

CGPROGRAM
#pragma vertex vert_surf
#pragma fragment frag_surf
#pragma fragmentoption ARB_precision_hint_fastest
#pragma multi_compile_fwdadd 
#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
#define UNITY_PASS_FORWARDADD
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define INTERNAL_DATA half3 TtoW0; half3 TtoW1; half3 TtoW2;
#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.TtoW0,normal), dot(data.TtoW1,normal), dot(data.TtoW2,normal)))
#define WorldNormalVector(data,normal) fixed3(dot(data.TtoW0,normal), dot(data.TtoW1,normal), dot(data.TtoW2,normal))
#line 1
#line 30

    //#pragma surface surf AlloyBrdf vertex:vert s
    #pragma target 3.0
	
	#include "Terrain-Cube.cginc"
	
struct v2f_surf {
  float4 pos : SV_POSITION;
  float4 pack0 : TEXCOORD0;
  float4 pack1 : TEXCOORD1;
  float2 pack2 : TEXCOORD2;
  float3 normal : TEXCOORD3;
  half3 lightDir : TEXCOORD4;
  half3 viewDir : TEXCOORD5;
  LIGHTING_COORDS(6,7)
};
float4 _Control_ST;
float4 _Splat0_ST;
float4 _Splat1_ST;
float4 _Splat2_ST;
float4 _Splat3_ST;
v2f_surf vert_surf (appdata_full v) {
  v2f_surf o;
  vert (v);
  o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _Control);
  o.pack0.zw = TRANSFORM_TEX(v.texcoord, _Splat0);
  o.pack1.xy = TRANSFORM_TEX(v.texcoord, _Splat1);
  o.pack1.zw = TRANSFORM_TEX(v.texcoord, _Splat2);
  o.pack2.xy = TRANSFORM_TEX(v.texcoord, _Splat3);
  TANGENT_SPACE_ROTATION; 
	o.normal = v.normal;
  float3 lightDir = mul (rotation, ObjSpaceLightDir(v.vertex));
  o.lightDir = lightDir;
  float3 viewDirForLight = mul (rotation, ObjSpaceViewDir(v.vertex));
  o.viewDir = viewDirForLight;
  TRANSFER_VERTEX_TO_FRAGMENT(o);
  return o;
}
fixed4 frag_surf (v2f_surf IN) : COLOR {
  Input surfIN;
  surfIN.uv_Control = IN.pack0.xy;
  surfIN.uv_Splat0 = IN.pack0.zw;
  surfIN.uv_Splat1 = IN.pack1.xy;
  surfIN.uv_Splat2 = IN.pack1.zw;
  surfIN.uv_Splat3 = IN.pack2.xy;
  #ifdef UNITY_COMPILER_HLSL
  AlloySurfaceOutput o = (AlloySurfaceOutput)0;
  #else
  AlloySurfaceOutput o;
  #endif  
  
  float3 worldRefl = mul ((float3x3)_Object2World, IN.viewDir);
  float4 tangent;
  tangent.xyz = cross(IN.normal, float3(0,0,1));
  tangent.w = -1;
  float3 binormal = cross( IN.normal, tangent.xyz ) * tangent.w;
  float3x3 rotation = float3x3(tangent.xyz, binormal, IN.normal);
  float4 TtoW0 = float4(mul(rotation, _Object2World[0].xyz), worldRefl.x)*unity_Scale.w;
  float4 TtoW1 = float4(mul(rotation, _Object2World[1].xyz), worldRefl.y)*unity_Scale.w;
  float4 TtoW2 = float4(mul(rotation, _Object2World[2].xyz), worldRefl.z)*unity_Scale.w;
  
  surfIN.worldRefl = float3(TtoW0.w, TtoW1.w, TtoW2.w);
  surfIN.TtoW0 = TtoW0.xyz;
  surfIN.TtoW1 = TtoW1.xyz;
  surfIN.TtoW2 = TtoW2.xyz;
  surfIN.worldNormal = 0.0;
  surfIN.viewDir = IN.viewDir;
  
  o.Albedo = 0.0;
  o.Emission = 0.0;
  o.Specular = 0.0;
  o.Alpha = 0.0;
  surf (surfIN, o);
  #ifndef USING_DIRECTIONAL_LIGHT
  fixed3 lightDir = normalize(IN.lightDir);
  #else
  fixed3 lightDir = IN.lightDir;
  #endif
  fixed4 c = LightingAlloyBrdf (o, lightDir, normalize(half3(IN.viewDir)), LIGHT_ATTENUATION(IN));
  c.a = 0.0;
  return c;
}
  
ENDCG
}  

Pass {
		Name "PREPASS"
		Tags { "LightMode" = "PrePassBase" }
		Fog {Mode Off}
CGPROGRAM
#pragma vertex vert_surf
#pragma fragment frag_surf
#pragma fragmentoption ARB_precision_hint_fastest
 
#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
#define UNITY_PASS_PREPASSBASE
#include "UnityCG.cginc"
#include "Lighting.cginc"

#define INTERNAL_DATA half3 TtoW0; half3 TtoW1; half3 TtoW2;
#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.TtoW0,normal), dot(data.TtoW1,normal), dot(data.TtoW2,normal)))
#define WorldNormalVector(data,normal) fixed3(dot(data.TtoW0,normal), dot(data.TtoW1,normal), dot(data.TtoW2,normal))
#line 1
#line 30

    //#pragma surface surf AlloyBrdf vertex:vert s
    #pragma target 3.0
	
	#include "Terrain-Cube.cginc"
	
struct v2f_surf {
  float4 pos : SV_POSITION;
  float4 pack0 : TEXCOORD0;
  float4 pack1 : TEXCOORD1;
  float2 pack2 : TEXCOORD2;
  float3 normal : TEXCOORD3;
  float3 TtoW0 : TEXCOORD4;
  float3 TtoW1 : TEXCOORD5;
  float3 TtoW2 : TEXCOORD6;
  float3 viewDir : TEXCOORD7;
};
float4 _Control_ST;
float4 _Splat0_ST;
float4 _Splat1_ST;
float4 _Splat2_ST;
float4 _Splat3_ST;
v2f_surf vert_surf (appdata_full v) {
  v2f_surf o;
  vert (v);
  o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _Control);
  o.pack0.zw = TRANSFORM_TEX(v.texcoord, _Splat0);
  o.pack1.xy = TRANSFORM_TEX(v.texcoord, _Splat1);
  o.pack1.zw = TRANSFORM_TEX(v.texcoord, _Splat2);
  o.pack2.xy = TRANSFORM_TEX(v.texcoord, _Splat3);
  TANGENT_SPACE_ROTATION;
	o.normal = v.normal;
  o.viewDir = mul (rotation, ObjSpaceViewDir(v.vertex));
  o.TtoW0 = mul(rotation, ((float3x3)_Object2World)[0].xyz)*unity_Scale.w;
  o.TtoW1 = mul(rotation, ((float3x3)_Object2World)[1].xyz)*unity_Scale.w;
  o.TtoW2 = mul(rotation, ((float3x3)_Object2World)[2].xyz)*unity_Scale.w;
  return o;
}
fixed4 frag_surf (v2f_surf IN) : COLOR {
  Input surfIN;
  surfIN.uv_Control = IN.pack0.xy;
  surfIN.uv_Splat0 = IN.pack0.zw;
  surfIN.uv_Splat1 = IN.pack1.xy;
  surfIN.uv_Splat2 = IN.pack1.zw;
  surfIN.uv_Splat3 = IN.pack2.xy;
  #ifdef UNITY_COMPILER_HLSL
  AlloySurfaceOutput o = (AlloySurfaceOutput)0;
  #else
  AlloySurfaceOutput o;
  #endif
  
  float3 worldRefl = mul ((float3x3)_Object2World, IN.viewDir)*unity_Scale.w;

  surfIN.worldRefl = worldRefl;
  surfIN.TtoW0 = IN.TtoW0.xyz;
  surfIN.TtoW1 = IN.TtoW1.xyz;
  surfIN.TtoW2 = IN.TtoW2.xyz;
  surfIN.worldNormal = 0.0;
  surfIN.viewDir = IN.viewDir;
  
  o.Albedo = 0.0;
  o.Emission = 0.0;
  o.Specular = 0.0;
  o.Alpha = 0.0;
  surf (surfIN, o);
  fixed3 worldN;
  worldN.x = dot(IN.TtoW0, o.Normal);
  worldN.y = dot(IN.TtoW1, o.Normal);
  worldN.z = dot(IN.TtoW2, o.Normal);
  o.Normal = worldN;
  fixed4 res;
  res.rgb = o.Normal * 0.5 + 0.5;
  res.a = o.Specular;
  return res;
}

ENDCG
}

Pass {
		Name "PREPASS"
		Tags { "LightMode" = "PrePassFinal" }
		ZWrite Off
CGPROGRAM
#pragma vertex vert_surf
#pragma fragment frag_surf
#pragma fragmentoption ARB_precision_hint_fastest
#pragma multi_compile_prepassfinal 
#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
#define UNITY_PASS_PREPASSFINAL
#include "UnityCG.cginc"
#include "Lighting.cginc"

#define INTERNAL_DATA half3 TtoW0; half3 TtoW1; half3 TtoW2;
#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.TtoW0,normal), dot(data.TtoW1,normal), dot(data.TtoW2,normal)))
#define WorldNormalVector(data,normal) fixed3(dot(data.TtoW0,normal), dot(data.TtoW1,normal), dot(data.TtoW2,normal))
#line 1
#line 30

    //#pragma surface surf AlloyBrdf vertex:vert s
    #pragma target 3.0
	
	#include "Terrain-Cube.cginc"
	
	struct v2f_surf {
  float4 pos : SV_POSITION;
  float4 pack0 : TEXCOORD0;
  float4 pack1 : TEXCOORD1;
  float2 pack2 : TEXCOORD2;
  float3 normal : TEXCOORD3;
  float4 screen : TEXCOORD4;
#ifdef LIGHTMAP_OFF
#else
  float2 lmap : TEXCOORD5;
#ifdef DIRLIGHTMAP_OFF
  float4 lmapFadePos : TEXCOORD6;
#endif
#endif
  float3 viewDir : TEXCOORD7;
};
#ifndef LIGHTMAP_OFF
float4 unity_LightmapST;
#endif
float4 _Control_ST;
float4 _Splat0_ST;
float4 _Splat1_ST;
float4 _Splat2_ST;
float4 _Splat3_ST;
v2f_surf vert_surf (appdata_full v) {
  v2f_surf o;
  vert (v);
  o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _Control);
  o.pack0.zw = TRANSFORM_TEX(v.texcoord, _Splat0);
  o.pack1.xy = TRANSFORM_TEX(v.texcoord, _Splat1);
  o.pack1.zw = TRANSFORM_TEX(v.texcoord, _Splat2);
  o.pack2.xy = TRANSFORM_TEX(v.texcoord, _Splat3);
  o.screen = ComputeScreenPos (o.pos);
#ifndef LIGHTMAP_OFF
  o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
  #ifdef DIRLIGHTMAP_OFF
    o.lmapFadePos.xyz = (mul(_Object2World, v.vertex).xyz - unity_ShadowFadeCenterAndType.xyz) * unity_ShadowFadeCenterAndType.w;
    o.lmapFadePos.w = (-mul(UNITY_MATRIX_MV, v.vertex).z) * (1.0 - unity_ShadowFadeCenterAndType.w);
  #endif
#else
#endif
  TANGENT_SPACE_ROTATION; 
	o.normal = v.normal;
  o.viewDir = mul (rotation, ObjSpaceViewDir(v.vertex));

  return o;
}
sampler2D _LightBuffer;
#if defined (SHADER_API_XBOX360) && defined (HDR_LIGHT_PREPASS_ON)
sampler2D _LightSpecBuffer;
#endif
#ifndef LIGHTMAP_OFF
sampler2D unity_Lightmap;
sampler2D unity_LightmapInd;
float4 unity_LightmapFade;
#endif
fixed4 unity_Ambient;
fixed4 frag_surf (v2f_surf IN) : COLOR {
  Input surfIN;
  surfIN.uv_Control = IN.pack0.xy;
  surfIN.uv_Splat0 = IN.pack0.zw;
  surfIN.uv_Splat1 = IN.pack1.xy;
  surfIN.uv_Splat2 = IN.pack1.zw;
  surfIN.uv_Splat3 = IN.pack2.xy;
  #ifdef UNITY_COMPILER_HLSL
  AlloySurfaceOutput o = (AlloySurfaceOutput)0;
  #else
  AlloySurfaceOutput o;
  #endif
  
  float3 worldRefl = mul ((float3x3)_Object2World, IN.viewDir);
  float4 tangent;
  tangent.xyz = cross(IN.normal, float3(0,0,1));
  tangent.w = -1;
  float3 binormal = cross( IN.normal, tangent.xyz ) * tangent.w;
  float3x3 rotation = float3x3(tangent.xyz, binormal, IN.normal);
  float4 TtoW0 = float4(mul(rotation, _Object2World[0].xyz), worldRefl.x)*unity_Scale.w;
  float4 TtoW1 = float4(mul(rotation, _Object2World[1].xyz), worldRefl.y)*unity_Scale.w;
  float4 TtoW2 = float4(mul(rotation, _Object2World[2].xyz), worldRefl.z)*unity_Scale.w;
  
  surfIN.worldRefl = float3(TtoW0.w, TtoW1.w, TtoW2.w);
  surfIN.TtoW0 = TtoW0.xyz;
  surfIN.TtoW1 = TtoW1.xyz;
  surfIN.TtoW2 = TtoW2.xyz;
  surfIN.worldNormal = 0.0;
  surfIN.viewDir = IN.viewDir;
  
  o.Albedo = 0.0;
  o.Emission = 0.0;
  o.Specular = 0.0;
  o.Alpha = 0.0;
  surf (surfIN, o);
  half4 light = tex2Dproj (_LightBuffer, UNITY_PROJ_COORD(IN.screen));
#if defined (SHADER_API_GLES)
  light = max(light, half4(0.001));
#endif
#ifndef HDR_LIGHT_PREPASS_ON
  light = -log2(light);
#endif
#if defined (SHADER_API_XBOX360) && defined (HDR_LIGHT_PREPASS_ON)
  light.w = tex2Dproj (_LightSpecBuffer, UNITY_PROJ_COORD(IN.screen)).r;
#endif
#ifndef LIGHTMAP_OFF
#ifdef DIRLIGHTMAP_OFF
  half3 lmFull = DecodeLightmap (tex2D(unity_Lightmap, IN.lmap.xy));
  half3 lmIndirect = DecodeLightmap (tex2D(unity_LightmapInd, IN.lmap.xy));
  float lmFade = length (IN.lmapFadePos) * unity_LightmapFade.z + unity_LightmapFade.w;
  half3 lm = lerp (lmIndirect, lmFull, saturate(lmFade));
  light.rgb += lm;
#else
  fixed4 lmtex = tex2D(unity_Lightmap, IN.lmap.xy);
  fixed4 lmIndTex = tex2D(unity_LightmapInd, IN.lmap.xy);
  half4 lm = LightingAlloyBrdf_DirLightmap(o, lmtex, lmIndTex,1);
  light += lm;
#endif
#else
  light.rgb += unity_Ambient.rgb;
#endif
  half4 c = LightingAlloyBrdf_PrePass (o, light);
  c.rgb += o.Emission;
  return c;
}

ENDCG
}
}

Dependency "AddPassShader" = "Hidden/Alloy/Nature/Terrain/Cube AddPass"
Dependency "BaseMapShader" = "Specular"

Fallback "Nature/Terrain/Bumped Specular"
}
