Shader "Custom/FireParticlesDissolve"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MaskTex ("DissolveTexture", 2D) = "white" {}
        _Speed("Speed", Range(-10,10)) = 1

    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Opaque"}
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha

	ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct VertexInput
            {
                float4 vertex : POSITION;
				fixed4 color : COLOR;
                float3 uv : TEXCOORD0;
                float3 uv2 : TEXCOORD1;
            };

            struct VertexOutput
            {
                float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
                float3 uv : TEXCOORD0;
                float3 uv2 : TEXCOORD1;
            };

            sampler2D _MainTex,_MaskTex;

            float4 _MainTex_ST;
            float4 _MaskTex_ST;
            fixed _Speed;
            fixed _Intensity;

            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv2.xy = TRANSFORM_TEX(v.uv, _MaskTex);
				o.color = v.color;
				o.uv.z = v.uv.z;
                return o;
            }

            fixed4 frag (VertexOutput i) : SV_Target
            {
                float particleTime = i.uv.z * _Speed;
                fixed4 diffuseTex = tex2D(_MaskTex, i.uv2).r;
                fixed4 color = tex2D(_MainTex, i.uv);
               
                half dissolve = smoothstep(particleTime, particleTime, diffuseTex);

				color *= dissolve * i.color;
                return color;
            }
            ENDCG
        }
    }
}