Shader "Book/08_RampShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _RampTex("Ramp Tex", 2D) = "white" {}
        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Tags { 
            "RenderType"="Opaque"
            "LightMode"="ForwardBase"
            }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 uv : TEXCOORD0; //uv
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            fixed4 _Color;
            sampler2D _RampTex;
            float4 _RampTex_ST;
            fixed4 _Specular;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _RampTex); //平铺和偏移后的纹理坐标
                o.worldNormal = UnityObjectToWorldNormal(v.normal); //输入的是法线
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldNormal = normalize(i.worldNormal).xyz;
                float3 worldLightDir = UnityWorldSpaceLightDir(i.worldPos).xyz;
                float3 worldViewDir = UnityWorldSpaceViewDir(i.worldPos).xyz;

                float halfLambert = 0.5 * dot(worldNormal, worldLightDir) + 0.5;
                fixed3 RampColor = tex2D(_RampTex, halfLambert.xx);

                fixed3 diffuse = _Color.rgb * RampColor.rgb * _LightColor0.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 halfDir = normalize(worldViewDir + worldLightDir);
                fixed3 specular = pow(max(dot(worldNormal, halfDir),0), _Gloss) * _Specular.rgb * _LightColor0.rgb;

                return fixed4(specular + ambient + diffuse, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}
