Shader "Custom/SmokeWithDistortion" 
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _MainTex("Main Texture", 2D) = "white"{}
        _DistortionNoiseTexture("Distortion Noise Texture", 2D) = "white"{}
        _DistortionSpeed("Distortion Speed", float) = 0.05
        _DistortionPower("Distortion Power", float) = 0.05
        _DistortionScale("Distortion Scale", float) = 1
    }
    Subshader
    {
        Tags{"RenderType" = "Transparent" "Queue" = "Transparent"}
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            
            HLSLPROGRAM
            
            #pragma vertex VS
            #pragma fragment PS
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float _DistortionSpeed;
            float _DistortionPower;
            float _DistortionScale;
            
            TEXTURE2D(_CameraOpaqueTexture);
            SAMPLER(sampler_CameraOpaqueTexture);

            TEXTURE2D(_DistortionNoiseTexture);
            SAMPLER(sampler_DistortionNoiseTexture);

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            CBUFFER_END
            
            struct VertexInput
            {
                float3 positionOS : POSITION;
                float2 UV : TEXCOORD;
                float3 normalOS : NORMAL;
                float4 color : COLOR;
            };

            struct VertexOutput
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : POSITION_WS;
                float2 UV : TEXCOORD;
                float3 normalWS : NORMAL;
                float4 screenUV : TEXCOORD1;
                float4 color : COLOR;
            };

            VertexOutput VS (VertexInput IN)
            {
                VertexOutput OUT;

                const float3 position_ws = TransformObjectToWorld(IN.positionOS);
                OUT.positionWS = position_ws;
                OUT.positionCS = TransformWorldToHClip(position_ws);
                OUT.color = IN.color;

                OUT.UV = IN.UV;
                OUT.screenUV = TransformWorldToHClip(position_ws);
                
                #if UNITY_UV_STARTS_AT_TOP
                    OUT.screenUV.y = -OUT.screenUV.y;
                #endif
                
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                return OUT;
            }
            
            float4 PS (VertexOutput IN) : SV_TARGET
            {
                float4 screenUV = IN.screenUV;
                screenUV *= rcp(screenUV.w); // Perspective Divide
                screenUV.xy = screenUV.xy * 0.5f + 0.5f;

                float time = _Time.y;
                float2 offset = float2(time * _DistortionSpeed, time * _DistortionSpeed);
                float3 noise = SAMPLE_TEXTURE2D(_DistortionNoiseTexture, sampler_DistortionNoiseTexture, IN.UV * _DistortionScale + offset) * 2 - 1;
                
                float3 RefractionSample = SAMPLE_TEXTURE2D(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, screenUV.xy + noise.rg * _DistortionPower).rgb;
                float4 mainColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.UV) * IN.color;
                return float4(lerp(RefractionSample,mainColor.rgb, mainColor.a), mainColor.a);
            }
            
            ENDHLSL
        }
    }
}