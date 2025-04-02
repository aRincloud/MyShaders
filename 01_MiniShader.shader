// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/01MiniShader"
{
    Properties
    {
        _MainColor("MainColor", Color) = (1,1,1,1.0)
        _Emission("Emission", Float) = 0.0
        // _CutOff("CutOff",Float) = 0.0
        // _MyRange("Range", Range(0.0,1.0 ) )= 0.0 
        // _Vector("Vector", Vector) = (0.0, 0.0, 0.0, 0.0)
        // _Color("Color", Color) = (0.0, 0.1, 0.2, 1.0)
        // _Texture("Texture", 2D) = "white" {}
        // _Speed("Speed", Float) = 1.0
        // _NoiseTex("_NoiseTex", 2D) = "white" {}

    }
    SubShader
    {
        Tags{"Queue" = "Transparent"}  // 半透明

        Pass{
            ZWrite Off //关掉
            // Blend SrcAlpha OneMinusSrcAlpha //透明
            Blend SrcAlpha One // 叠加
            // Cull Off //不剔除任何面,反面也渲染
            // Cull Back // 剔除反面
            CGPROGRAM
            #pragma vertex vert // 定义顶点着色器的输出函数
            #pragma fragment frag // 定义片段着色器的输出函数
            #include "UnityCG.cginc"

            
            float4 _MainColor;
            float _Emission;
            // sampler2D _Texture;
            // float4 _Texture_ST;
            // float _Speed;
            // float _CutOff;
            // sampler2D _NoiseTex;
            // float4 _Noise_ST;


            struct appdata  // 应用阶段，拿到模型的一些数据
            {
                float4 vertex : POSITION;  //顶点空间坐标
                float2 uv : TEXCOORD0; //UV 坐标
                // float3 normal : NORMAL;
                // float4 color : COLOR; //顶点色
            };

            struct v2f // 定义顶点着色器的输出类型，用于输入给片段着色器
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                // float2 pos_uv : TEXCOORD1;

            };

            v2f vert(appdata v) // 顶点着色器
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex); // 物体坐标转屏幕坐标
                //  * _Texture_ST.xy + _Texture_ST.zw;
                o.uv = v.uv;
                return o;
            };

            fixed4 frag(v2f i) : SV_Target //片段着色器
            {
                float2 Center = float2(0.5, 0.5);
                // fixed4 col = tex2D(_Texture, i.uv );
                half2 RelativePos = i.uv - Center;
                half len = length(RelativePos);
                half angle = atan2(RelativePos.y, RelativePos.x);
                half light =  sin(len * UNITY_PI *4 - 0.5 * UNITY_PI) * 0.5 + 0.5;
                fixed3 col = _MainColor.xyz * light * _Emission;
                fixed alpha = saturate(_MainColor.a * light * _Emission);


                // half4 col = tex2D(_Texture, i.uv);

                clip(0.5 - len);
                return fixed4(col, alpha);
            };
            ENDCG

        }
    }
}
