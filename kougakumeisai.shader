Shader "Custom/MyShader" {
	Category{

		Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }

		//// We must be transparent, so other objects are drawn before this one.
		//Tags{ "Queue" = "Transparent" "RenderType" = "Opaque" }


		SubShader{

		// This pass grabs the screen behind the object into a texture.
		// We can access the result in the next pass as _GrabTexture
		GrabPass{
		Name "BASE"
		Tags{ "LightMode" = "Always" }
	}

		// Main pass: Take the texture grabbed above and use the bumpmap to perturb it
		// on to the screen
		Pass{
		Name "BASE"
		Tags{ "LightMode" = "Always" }

		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

	struct appdata{
		float4 vertex : POSITION;
		half2 uv : TEXCOORD0;
		half3 normal : NORMAL;
	};

	struct v2f {
		float4 pos : SV_POSITION;
		float4 uvgrab : TEXCOORD0;
		float3 normal : TEXCOORD1;
		float3 view : TEXCOORD2;
	};


	v2f vert(appdata v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);

		o.uvgrab = ComputeGrabScreenPos(o.pos);

		o.normal = normalize(mul(v.normal, unity_WorldToObject)).xyz;

		o.view = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex).xyz);

		return o;
	}


	sampler2D _GrabTexture;
	float4 _GrabTexture_TexelSize;

	half4 frag(v2f i) : SV_Target
	{
		float2 offset = i.view.xy - i.normal.xy;
		//float2 offset = - i.normal.xy;
#if UNITY_UV_STARTS_AT_TOP
		float scale = -1.0;
#else
		float scale = 1.0;
#endif
		offset.y *= scale;
		float p = dot(i.normal, i.view);
		offset.x *= _GrabTexture_TexelSize.x * p;
		offset.y *= _GrabTexture_TexelSize.y * p;
		offset *= 100;
		float4x4  m = float4x4(
			1.0f, 0.0f, 0.0f, offset.x,
			0.0f, 1.0f, 0.0f, offset.y,
			0.0f, 0.0f, 1.0f, 0.0f,
			0.0f, 0.0f, 0.0f, 1.0f);
		float4 pos = mul(i.uvgrab, m);

		half4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(pos));
		return col;
		//return half4(1,1,1,1);
	}
		ENDCG
	}
	}
	}

}
