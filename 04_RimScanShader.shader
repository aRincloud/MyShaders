Shader "Unlit/01MiniShader"
{
    Properties
    {
        _MainColor("MainColor", Color) = (1,1,1,1.0)
        _Emission("Emission", Float) = 1.0
        _RimPower("RimPower", float) = 2.0
        _Speed("Speed", float) = 1.0
        _Length("Length", float) = 3.14
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" } 

        Pass
        {
            // Tags { "LightMode" = "ForwardBase" }
            Cull Back
            ZTest LEqual
            ZWrite Off
            Blend One OneMinusSrcAlpha // ✅ 修正混合模式，保证透明度正常

            HLSLPROGRAM
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
                float pos_y : TEXCOORD2;
            };

            uniform float4 _MainColor;
            uniform float _Emission;
            uniform float _RimPower;
            uniform float _Speed;
            uniform float _Length;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos_y = v.vertex.y;
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

                float scan_rim = max(sin( i.pos_y * UNITY_PI + _Time.y * _Speed) - _Length, 0);
                scan_rim = pow(scan_rim / (1- _Length), _RimPower) * _Emission;

                rim = max(rim , scan_rim);


                return half4(_MainColor.rgb * _Emission * rim, saturate(rim));
                // return scan_rim.xxxx;
            }
            ENDHLSL
        }
    }
}
