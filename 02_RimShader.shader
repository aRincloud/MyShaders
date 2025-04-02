Shader "Unlit/01MiniShader"
{
    Properties
    {
        _MainColor("MainColor", Color) = (1,1,1,1.0)
        _Emission("Emission", Float) = 1.0
        _RimPower("RimPower", float) = 2.0
    }
    SubShader
    {
        

        Pass 
        {
            Tags { "Queue"="Transparent" "RenderType"="Transparent" } 
            Cull Back
            Zwrite On
            ColorMask 0

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f{
                float4 pos : SV_POSITION;
            };
            
            v2f vert ( float4 vertex : POSITION) {
                v2f o;
                o.pos = UnityObjectToClipPos(vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                return (1,1,1,0);
            }

            ENDCG
        }
        
        Pass
        {
            Tags { "Queue"="Transparent" "RenderType"="Transparent" } 
            ZWrite On
            Blend One OneMinusSrcAlpha // ✅ 修正混合模式，保证透明度正常

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                half3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 pos_world : TEXCOORD0;
                float3 normal_world : TEXCOORD1;
            };

            uniform float4 _MainColor;
            uniform float _Emission;
            uniform float _RimPower;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal_world = UnityObjectToWorldNormal(v.normal);
                o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                float3 normal_world = normalize(i.normal_world);
                float3 view_world = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
                float NdotV = 1.0 - saturate(dot(normal_world, view_world));
                float rim = pow(NdotV, _RimPower) * _Emission;
                float alpha = saturate(rim);  
                float3 col = _MainColor.rgb * _Emission * rim;

                return half4(col,alpha);
            }
            ENDCG
        }
    }
}
