Shader "Custom/Hue Shift" {
	Properties {
		_MainTex ("Render Input", 2D) = "white" {}
		_Shift ("Hue Shift", Range (0,1)) = 0.4
	}
	SubShader {
		ZTest Always Cull Off ZWrite Off Fog { Mode Off }
		Pass {
			CGPROGRAM
				#pragma vertex vert_img
				#pragma fragment frag
				#include "UnityCG.cginc"
			
				sampler2D _MainTex;
				float _Shift;
			
				float3 rgb2hsv(float3 c)
				{
					float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
					float4 p = c.g < c.b ? float4(c.bg, K.wz) : float4(c.gb, K.xy);
					float4 q = c.r < p.x ? float4(p.xyw, c.r) : float4(c.r, p.yzx);

					float d = q.x - min(q.w, q.y);
					float e = 1.0e-10;
					return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
				}

				float3 hsv2rgb(float3 c)
				{
					float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
					float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
					return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
				}

				float4 frag(v2f_img IN) : COLOR {
					half4 c = tex2D (_MainTex, IN.uv);
					float3 hsv = rgb2hsv(c.xyz);
					hsv.x += _Shift;
					
					c.rgb = hsv2rgb(hsv);

					return c;
				}
			ENDCG
		}
	}
}