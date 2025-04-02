Shader "Book/07_Normal"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("MainTex", 2D) = "white" {}
        _BumpMap("Normal Map", 2D) = "blue" {}
        _BumpScale("Bump Scale", Float) = 1.0
        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }
    SubShader{
        // 在切线空间中计算
        // Pass{
        //     Tags { "LightMode"="ForwardBase"}

        //     CGPROGRAM

        //     #pragma vertex vert
        //     #pragma fragment frag
        //     #include "Lighting.cginc"
        //     #include "UnityCG.cginc"

        //     fixed4 _Color;
        //     sampler2D _MainTex;
        //     float4 _MainTex_ST;
        //     sampler2D _BumpMap;
        //     float4 _BumpMap_ST;
        //     float _BumpScale;
        //     fixed4 _Specular;
        //     float _Gloss;

        //     struct appdata {
        //         float4 vertex : POSITION;
        //         float3 normal : NORMAL;
        //         float4 texcoord : TEXCOORD0;
        //         float4 tangent : TANGENT; //切线信息，得到每个顶点的切线。而蓝色的法线图是在切线空间中的
        //     };

        //     struct v2f {
        //         float4 pos : SV_POSITION;
        //         float3 lightDir : TEXCOORD0;
        //         float3 viewDir : TEXCOORD1;
        //         float4 uv : TEXCOORD2;  // xy 分量：——MainTex，zw 分量：_NormalTex坐标 一般来讲只有float2同一套就够了
        //     };

        //     v2f vert (appdata v) {
        //         v2f o;
        //         o.pos = UnityObjectToClipPos(v.vertex);

        //         o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
        //         o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw; //

        //         TANGENT_SPACE_ROTATION; //得到rotation，从模型空间到切线空间的变换矩阵

        //         o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
        //         o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

        //         return o;
        //     }

        //     fixed4 frag ( v2f i) : SV_Target {
        //         // 由于已经得到了切线空间下的光照和摄像机方向，只需要在这个空间下计算法线方向和光照
        //         fixed3 tangentLightDir = normalize(i.lightDir);
        //         fixed3 tangentViewDir = normalize(i.viewDir);

        //         // 法线
        //         /*
        //          法线纹理中存储的是把法线经过映射后得到 的像素值 ， 因此我们需要把它们反映射 回来。
        //         如果我们没有在 Unity 里把该法线纹理的类型设置成 Normal map 就需要在代码中手动进行这个过程。
        //         */
        //         fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
        //         fixed3 tangentNormal = UnpackNormal(packedNormal); 
        //         tangentNormal.xy *= _BumpScale;
        //         tangentNormal.z = sqrt(1.0- saturate(dot(tangentNormal.xy, tangentNormal.xy)));

        //         //  漫反射颜色
        //         fixed3 albedo = tex2D(_MainTex, i.uv) * _Color.rgb;

        //         fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

        //         fixed3 diffuse = _LightColor0 * albedo * max(0, dot(tangentNormal, tangentLightDir));

        //         fixed3 halfDir = normalize(tangentViewDir + tangentLightDir);
        //         fixed3 specular = _LightColor0 * _Specular * pow(max(dot(tangentNormal, halfDir), 0), _Gloss);

        //         return fixed4( ambient + diffuse + specular, 1.0 );
        //     }

        // 在世界空间中计算，也就是使用从切线空间转到发现空间的变换矩阵。如果在片段着色器中计算光照，需要传递矩阵
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
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Specular;
            float _Gloss;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
                float4 tangent : TANGENT; //切线信息，得到每个顶点的切线。而蓝色的法线图是在切线空间中的
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;  // xy 分量：——MainTex，zw 分量：_NormalTex坐标 一般来讲只有float2同一套就够了
                // 实际上，对方向矢量的变换只需要使用 3X3 大小的矩阵，也就是说，每一行只需要使用 float3 类型的变量即可。但为了充分利用插值寄存器的存储空间，我们把世界空间下的顶点位置存储在这些变量的 w 分量中
                float4 T2W0 : TEXCOORD1;
                float4 T2W1 : TEXCOORD2;
                float4 T2W2 : TEXCOORD3;
            };

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw; //

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex); //传下去用来找光照\视角方向

                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                // 因为tangent空间下， normal, tangent bio分别是三个坐标轴，因此可以根据他们在世界坐标下的位置,计算出变换矩阵
                o.T2W0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.T2W1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.T2W2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                return o;
            }

            fixed4 frag ( v2f i) : SV_Target {
                float3 worldPos = float3(i.T2W0.w, i.T2W1.w, i.T2W2.w);

                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                tangentNormal *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy))); //确保x2+y2+z2=1
                
                fixed3 bump =  fixed3(dot(i.T2W0.xyz, tangentNormal.x), dot(i.T2W1.xyz, tangentNormal.y), dot(i.T2W2.xyz, tangentNormal.z));
                bump = normalize(bump);

                //  漫反射颜色
                fixed3 albedo = tex2D(_MainTex, i.uv.xy) * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0 * albedo * max(0, dot(bump, lightDir));

                fixed3 halfDir = normalize(viewDir + lightDir);
                fixed3 specular = _LightColor0 * _Specular * pow(max(dot(bump, halfDir), 0), _Gloss);

                return fixed4( ambient + diffuse + specular, 1.0 );

            }
        
            


            ENDCG
        }
        
    }
    Fallback "Specular"
}
