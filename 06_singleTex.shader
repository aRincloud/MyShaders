Shader "Book/06_SingleTex"
{
    Properties{
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("MainTex", 2D) = "white" {}
        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }

    SubShader{
        Pass{
            Tags { "LightMode"="ForwardBase"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Specular;
            float _Gloss;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2; 
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex); // 模型坐标转屏幕裁剪坐标
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                /*
                注意：以下仅可用于向前渲染
                UnityObjectToWorldNormal 输入##模型空间##法线，得到世界空间该法线
                UnityObjectToWorldDir 把方向矢量从--模型--空间便道世界空间
                UnityObjectToObjectDir 把方向矢量从世界空间便道--模型==空间
                */
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz; // 模型坐标转世界坐标
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            fixed4 frag ( v2f i) : SV_Target {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                /*
                注意：以下仅可用于向前渲染
                WorldSpaceLightDir 输入##模型空间##顶点位置，得到世界空间该点到light方向
                UnityWorldSpaceLightDir 输入##世界空间##顶点位置，得到世界空间该点到light方向
                ObjSpaceLightDir 输入模型空间顶点位置，得到##模型##空间该点到light方向
                */

                //  漫反射颜色
                fixed3 albedo = tex2D(_MainTex, i.uv) * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0 * albedo * max(0, dot(worldNormal, worldLightDir));

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos)); // 根据物体的世界空间坐标，得到view的世界空间
                // 还有_WorldSpaceViewDir() 输入模型空间的坐标，得到view世界空间方向
                // ObjSpaceViewDir 输入物体空间的坐标，得到View模型空间方向
                //都是该点->camera的方向
                fixed3 halfDir = normalize(viewDir + worldLightDir);
                fixed3 specular = _LightColor0 * _Specular * pow(max(dot(worldNormal, halfDir), 0), _Gloss);

                return fixed4( ambient + diffuse + specular, 1.0 );
            }

            


            ENDCG
        }
        
    }
    Fallback "Specular"
}
