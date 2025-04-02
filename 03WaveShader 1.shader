// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/01MiniShader"
{
    Properties
    {
        _MainColor("MainColor", Color) = (1,1,1,1.0)
        _CutOff("CutOff",Float) = 0.0
        _AngleScale("AngleScale",Float) = 0.2
        _LenScale("LenScale",Float) = 2
        _Speed("Speed", Float) = 3.0
        _NoiseTex("_NoiseTex", 2D) = "white" {}

    }
    SubShader
    {
        // Tags{"Queue" = "Transparent"}  // 半透明

        Pass{

            CGPROGRAM
            #pragma vertex vert // 定义顶点着色器的输出函数
            #pragma fragment frag // 定义片段着色器的输出函数
            #include "UnityCG.cginc"

            
            float4 _MainColor;
            float _AngleScale;
            float _LenScale;
            float _Speed;
            float _CutOff;
            sampler2D _NoiseTex;
            float4 _Noise_ST;


            struct appdata  // 应用阶段，拿到模型的一些数据
            {
                float4 vertex : POSITION;  //顶点空间坐标
                float2 uv : TEXCOORD0; //UV 坐标
            };

            struct v2f // 定义顶点着色器的输出类型，用于输入给片段着色器
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata v) // 顶点着色器
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex); // 物体坐标转屏幕坐标
                o.uv = v.uv;
                return o;
            };

            fixed4 frag(v2f i) : SV_Target //片段着色器
            {
                float2 Center = float2(0.5, 0.5);
                // polarPos
                half2 RelativePos = i.uv - Center;
                half len = length(RelativePos);
                half angle = atan2(RelativePos.y, RelativePos.x) ;

                half light =  sin(len * UNITY_PI *4 *1.5 - 0.5 * UNITY_PI - _Time.y * _Speed) * 0.5 + 0.5;

                half2 polarPos = float2( max(angle, -angle) / UNITY_PI * _AngleScale, len * _LenScale -  _Time.y * _Speed * 0.2);
                fixed4 noise = tex2D(_NoiseTex, polarPos);

                clip(0.5 - len);
                clip(light + noise- _CutOff);
                return _MainColor;
            };
            ENDCG

        }
    }
}
