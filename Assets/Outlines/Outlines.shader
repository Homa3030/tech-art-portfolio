Shader "Hidden/Outlines" 
{
    Properties
    {
        _MainTex ("Source", 2D) = "white"{}
    }
    Subshader
    {
        Pass
        {
            HLSLPROGRAM
            
            #pragma vertex VS
            #pragma fragment PS
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_TexelSize;
            float _ColorThreshold;
            float _DepthThreshold;
            float _NormalsThreshold;
            
            struct VertexInput
            {
                float3 positionOS : POSITION;
                float2 UV : TEXCOORD;
            };

            struct VertexOutput
            {
                float4 positionCS : SV_POSITION;
                float2 UV : TEXCOORD;
            };

            VertexOutput VS (VertexInput IN)
            {
                VertexOutput OUT;

                const float3 position_ws = TransformObjectToWorld(IN.positionOS);
                OUT.positionCS = TransformWorldToHClip(position_ws);
                
                OUT.UV = IN.UV;

                return OUT;
            }

            float ManhattanLength(float3 v)
            {
                return abs(v.x) + abs(v.y) + abs(v.z);
            }

            float SobelColor(float2 uv)
            {
                const float3 right = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + float2(_MainTex_TexelSize.x, 0)).rgb;
                const float3 rightTop = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + float2(_MainTex_TexelSize.x, _MainTex_TexelSize.y)).rgb;
                const float3 rightBottom = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + float2(_MainTex_TexelSize.x, -_MainTex_TexelSize.y)).rgb;

                const float3 left = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + float2(-_MainTex_TexelSize.x, 0)).rgb;
                const float3 leftTop = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + float2(-_MainTex_TexelSize.x, _MainTex_TexelSize.y)).rgb;
                const float3 leftBottom = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + float2(-_MainTex_TexelSize.x, -_MainTex_TexelSize.y)).rgb;
                
                const float3 top = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + float2(0, _MainTex_TexelSize.y)).rgb;
                const float3 bottom = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + float2(0, -_MainTex_TexelSize.y)).rgb;

                const float3 sobelHorizontalSum = -(leftTop + 2 * left + leftBottom) + rightTop + 2 * right + rightBottom;
                const float3 sobelVerticalSum = leftTop + 2 * top + rightTop -(leftBottom + 2 * bottom + rightBottom);
                
                return max(ManhattanLength(sobelHorizontalSum), ManhattanLength(sobelVerticalSum));
            }

            float SobelDepth(float2 uv)
            {
                const float right = LinearDepthToEyeDepth(SampleSceneDepth(uv + float2(_MainTex_TexelSize.x, 0)));
                const float rightTop = LinearDepthToEyeDepth(SampleSceneDepth(uv + float2(_MainTex_TexelSize.x, _MainTex_TexelSize.y)));
                const float rightBottom = LinearDepthToEyeDepth(SampleSceneDepth(uv + float2(_MainTex_TexelSize.x, -_MainTex_TexelSize.y)));
                
                const float left = LinearDepthToEyeDepth(SampleSceneDepth(uv + float2(-_MainTex_TexelSize.x, 0)));
                const float leftTop = LinearDepthToEyeDepth(SampleSceneDepth(uv + float2(-_MainTex_TexelSize.x, _MainTex_TexelSize.y)));
                const float leftBottom = LinearDepthToEyeDepth(SampleSceneDepth(uv + float2(-_MainTex_TexelSize.x, -_MainTex_TexelSize.y)));
                
                const float top = LinearDepthToEyeDepth(SampleSceneDepth(uv + float2(0, _MainTex_TexelSize.y)));
                const float bottom = LinearDepthToEyeDepth(SampleSceneDepth(uv + float2(0, -_MainTex_TexelSize.y)));

                const float sobelHorizontalSum = -(leftTop + 2 * left + leftBottom) + rightTop + 2 * right + rightBottom;
                const float sobelVerticalSum = leftTop + 2 * top + rightTop -(leftBottom + 2 * bottom + rightBottom);
                
                return max(ManhattanLength(sobelHorizontalSum), ManhattanLength(sobelVerticalSum));
            }

            float SobelNormals(float2 uv)
            {
                const float3 right = SampleSceneNormals(uv + float2(_MainTex_TexelSize.x, 0));
                const float3 rightTop = SampleSceneNormals(uv + float2(_MainTex_TexelSize.x, _MainTex_TexelSize.y));
                const float3 rightBottom = SampleSceneNormals(uv + float2(_MainTex_TexelSize.x, -_MainTex_TexelSize.y));

                const float3 left = SampleSceneNormals(uv + float2(-_MainTex_TexelSize.x, 0));
                const float3 leftTop = SampleSceneNormals(uv + float2(-_MainTex_TexelSize.x, _MainTex_TexelSize.y));
                const float3 leftBottom = SampleSceneNormals(uv + float2(-_MainTex_TexelSize.x, -_MainTex_TexelSize.y));

                const float3 top = SampleSceneNormals(uv + float2(0, _MainTex_TexelSize.y));
                const float3 bottom = SampleSceneNormals(uv + float2(0, -_MainTex_TexelSize.y));

                const float sobelHorizontalSum = -(leftTop + 2 * left + leftBottom) + rightTop + 2 * right + rightBottom;
                const float sobelVerticalSum = leftTop + 2 * top + rightTop -(leftBottom + 2 * bottom + rightBottom);
                
                return max(ManhattanLength(sobelHorizontalSum), ManhattanLength(sobelVerticalSum));
            }

            float4 PS (VertexOutput IN) : SV_TARGET
            {
                float4 sourceSample = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.UV);
                if (SobelColor(IN.UV) > _ColorThreshold || SobelDepth(IN.UV) > _DepthThreshold || SobelNormals(IN.UV) > _NormalsThreshold)
                {
                    return 0;
                }
                return sourceSample;
            }
            
            ENDHLSL
        }
    }
}