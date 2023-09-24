Shader "Custom/TriplanarShader"
{
    Properties
    {
        _Sharpness("Blend Sharpness", Range(1, 64)) = 1
        
        [Header(Front Texture Properties)]
        _ColorFront("Color", color) = (1, 1, 1, 1)
        _TextureFront("Texture", 2D) = "white"{}
        [NoScaleOffset][Normal] _NormalMapFront("Normal", 2D) = "bump" {}
        _NormalStrengthFront("Normal strength", range(0, 5)) = 1
        
        [Header(Side Texture Properties)]
        _ColorSide("Color", color) = (1, 1, 1, 1)
        _TextureSide("Texture", 2D) = "white"{}
        [NoScaleOffset][Normal] _NormalMapSide("Normal", 2D) = "bump" {}
        _NormalStrengthSide("Normal strength", range(0, 5)) = 1
        
        [Header(Top Texture Properties)]
        _ColorTop("Color", color) = (1, 1, 1, 1)
        _TextureTop("Texture", 2D) = "white"{}
        [NoScaleOffset][Normal] _NormalMapTop("Normal", 2D) = "bump" {}
        _NormalStrengthTop("Normal strength", range(0, 5)) = 1
    }
    Subshader
    {
        Tags {"RenderPipeline" = "UniversalPipeline" "RenderType"="Opaque"}
        Pass
        {
            Name "Triplanar"
            Tags {"LightMode" = "UniversalForward"}
            
            HLSLPROGRAM

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            
            #pragma vertex VS
            #pragma fragment PS
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            TEXTURE2D(_TextureFront); SAMPLER(sampler_TextureFront);
            TEXTURE2D(_NormalMapFront); SAMPLER(sampler_NormalMapFront);

            TEXTURE2D(_TextureSide); SAMPLER(sampler_TextureSide);
            TEXTURE2D(_NormalMapSide); SAMPLER(sampler_NormalMapSide);
            
            TEXTURE2D(_TextureTop); SAMPLER(sampler_TextureTop);
            TEXTURE2D(_NormalMapTop); SAMPLER(sampler_NormalMapTop);

            CBUFFER_START(UnityPerMaterial)
            float4 _ColorFront;
            float4 _TextureFront_ST;
            float4 _ColorSide;
            float4 _TextureSide_ST;
            float4 _ColorTop;
            float4 _TextureTop_ST;
            float _NormalStrengthFront;
            float _NormalStrengthSide;
            float _NormalStrengthTop;
            float _Sharpness;
            CBUFFER_END
            
            struct VertexInput
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct VertexOutput
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : POSITION_WS;
                float3 normalWS : NORMAL_WS;

                DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 1);
            };

            VertexOutput VS (VertexInput IN)
            {
                VertexOutput OUT;
                
                OUT.positionCS = TransformObjectToHClip(IN.positionOS);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS);

                const VertexNormalInputs normalInputs = GetVertexNormalInputs(IN.normalOS);
                OUT.normalWS = normalInputs.normalWS;

                OUTPUT_SH(OUT.normalWS.xyz, OUT.vertexSH);
                
                return OUT;
            }
            
            float4 PS(VertexOutput IN) : SV_TARGET {
                const float3 rawWeights = normalize(IN.normalWS);
                float3 weights = abs(rawWeights);
                weights = pow(weights, _Sharpness);
                weights = weights / (weights.x + weights.y + weights.z);
                
                float2 uvFront = TRANSFORM_TEX(IN.positionWS.xy, _TextureFront);
                float2 uvSide = TRANSFORM_TEX(IN.positionWS.zy, _TextureSide);
                float2 uvTop = TRANSFORM_TEX(IN.positionWS.xz, _TextureTop);

                float4 colorFront = SAMPLE_TEXTURE2D(_TextureFront, sampler_TextureFront, uvFront) * _ColorFront;
                float4 colorSide = SAMPLE_TEXTURE2D(_TextureSide, sampler_TextureSide, uvSide) * _ColorSide;
                float4 colorTop = SAMPLE_TEXTURE2D(_TextureTop, sampler_TextureTop, uvTop) * _ColorTop;
                
                colorFront *= weights.z;
                colorSide *= weights.x;
                colorTop *= weights.y;
                
                float4 color = colorFront + colorSide + colorTop;
                
                float3 normalTSFront = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMapFront, sampler_NormalMapFront, uvFront), _NormalStrengthFront);
                float3 normalTSSide = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMapSide, sampler_NormalMapSide, uvSide), _NormalStrengthSide);
                float3 normalTSTop = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMapTop, sampler_NormalMapTop, uvTop), _NormalStrengthTop);
                
                float3 normalWSFront = float3(normalTSFront.xy + IN.normalWS.xy, IN.normalWS.z);
                float3 normalWSSide = float3(normalTSSide.xy + IN.normalWS.zy, IN.normalWS.x);
                float3 normalWSTop = float3(normalTSTop.xy + IN.normalWS.xz, IN.normalWS.y);

                const float3 normalWS = normalize(
                    normalWSSide.zyx * weights.x +
                    normalWSTop.xzy * weights.y +
                    normalWSFront.xyz * weights.z
                    );

                InputData lightingInput = (InputData)0;
                lightingInput.positionWS = IN.positionWS;
                lightingInput.positionCS = IN.positionCS;
                lightingInput.normalWS = normalWS;
                lightingInput.viewDirectionWS = GetWorldSpaceNormalizeViewDir(IN.positionWS);
                lightingInput.shadowCoord = TransformWorldToShadowCoord(IN.positionWS);
                lightingInput.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.positionCS);
                lightingInput.bakedGI = SAMPLE_GI(IN.staticLightmapUV, IN.vertexSH, normalWS);;
                
	            SurfaceData surfaceInput = (SurfaceData)0;
                surfaceInput.albedo =  color.xyz;
                surfaceInput.occlusion = 1;
                surfaceInput.smoothness = 0.1;
                surfaceInput.metallic = 0;
                
                return UniversalFragmentPBR(lightingInput, surfaceInput);
            }
            ENDHLSL
        }
        
        Pass 
        {
            Name "TriplanarShadowCaster"
            Tags {"LightMode" = "ShadowCaster"}
            
            HLSLPROGRAM

            #pragma vertex VS
            #pragma fragment PS

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"\

            float3 _LightDirection;

            struct VertexInput
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            float4 GetShadowCasterPositionCS(float3 positionWS, float3 normalWS)
            {
                const float3 lightDirectionWS = _LightDirection;
                
                float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));
            #if UNITY_REVERSED_Z
                positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
            #else
                positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
            #endif
                return positionCS;
            }

            float4 VS(VertexInput IN) : SV_POSITION
            {
                const float3 positionWS = TransformObjectToWorld(IN.positionOS);
                const float3 normalWS = TransformObjectToWorldNormal(IN.normalOS);
                return GetShadowCasterPositionCS(positionWS, normalWS);
            }

            float4 PS() : SV_TARGET
            {
                return 0;
            }

            ENDHLSL
        }
            
    }
}
