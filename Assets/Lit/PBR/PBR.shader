Shader "Custom/PBR" 
{
    Properties
    {
        [MainColor] _Color("Color", color) = (1, 1, 1, 1)
        [MainTexture] _Texture("Texture", 2D) = "white"{}
        _Cutoff("Aplha cutout threshold", range(0, 1)) = 0.5
        
        //Red channel - Metallic mask
        //Green channel - Smoothness mask
        [HideInInspector]
        [NoScaleOffset] _Mask("Mask" , 2D) = "white" {}
        _Metallic("Metallic strength", range(0, 1)) = 0
        _Smoothness("Smoothness", range(0, 1)) = 0
        
        [NoScaleOffset][Normal] _NormalMap("Normal", 2D) = "bump" {}
        _NormalStrength("Normal strength", range(0, 1)) = 1
        
        [Toggle(_SPECULAR_SETUP)] _SpecularSetupToggle("Use specular setup workflow", float) = 0
        [NoScaleOffset] _SpecularMap("Specular map", 2D) = "white" {}
        _SpecularColor("Specular color", color) = (1, 1, 1, 1)
        
        [NoScaleOffset] _EmissionMap("Emission map", 2D) = "white" {}
        [HDR]_EmissionColor("_Emission color", Color) = (0, 0, 0, 0)
        
        [NoScaleOffset] _ParallaxMap("Height map", 2D) = "white" {}
        _ParallaxStrength("Parallax strength", Range(0, 1)) = 0.005 
        
        [HideInInspector] _Cull("Cull Mode", float) = 2
        [HideInInspector] _SourceBlend("Source blend", Float) = 0
        [HideInInspector] _DestBlend("Destination blend", Float) = 0
        [HideInInspector] _ZWrite("ZWrite", Float) = 0
        [HideInInspector] _SurfaceType("Surface type", Float) = 0
        [HideInInspector] _BlendType("Blend type", Float) = 0
        [HideInInspector] _FaceRenderingMode("Face rendering type", Float) = 0
    }
    Subshader
    {
        Tags {"RenderPipeline" = "UniversalPipeline" "RenderType"="Opaque"}
        Pass
        {
            Name "ForwardLit"
            Tags {"LightMode" = "UniversalForward"}
            
            ZWrite[_ZWrite]
            Cull[_Cull]
            
            HLSLPROGRAM

            #define _SPECULAR_COLOR

            #pragma shader_feature_local _ALPHA_CUTOUT
            #pragma shader_feature_local _DOUBLE_SIDED_NORMALS
            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local_fragment _NORMALMAP
            
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ DEBUG_DISPLAY
            
            #pragma vertex VS
            #pragma fragment PS
            
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_Mask); SAMPLER(sampler_Mask);
            TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);
            TEXTURE2D(_SpecularMap); SAMPLER(sampler_SpecularMap);
            TEXTURE2D(_EmissionMap); SAMPLER(sampler_EmissionMap);
            TEXTURE2D(_ParallaxMap); SAMPLER(sampler_ParallaxMap);

            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float4 _Texture_ST;
            float _Cutoff;
            float _Smoothness;
            float _Metallic;
            float _NormalStrength;
            float3 _SpecularColor;
            float3 _EmissionColor;
            float _ParallaxStrength;
            CBUFFER_END
            
            #include "Assets/Lit/Common.hlsl"
            
            struct VertexInput
            {
                float3 positionOS : POSITION;
                float2 UV : TEXCOORD;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
            };

            struct VertexOutput
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : POSITION_WS;
                float2 UV : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float4 tangentWS : TEXCOORD2;

                DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 3);
            };

            VertexOutput VS (VertexInput IN)
            {
                VertexOutput OUT;
                
                OUT.positionCS = TransformObjectToHClip(IN.positionOS);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS);
                
                OUT.UV = IN.UV * _Texture_ST.xy + _Texture_ST.zw;

                VertexNormalInputs normalInputs = GetVertexNormalInputs(IN.normalOS, IN.tangentOS);
                OUT.normalWS = normalInputs.normalWS;
                OUT.tangentWS = float4(normalInputs.tangentWS, IN.tangentOS.w);

                OUTPUT_SH(OUT.normalWS.xyz, OUT.vertexSH);
                
                return OUT;
            }
            
            float4 PS(VertexOutput IN
            #ifdef _DOUBLE_SIDED_NORMALS
	            , FRONT_FACE_TYPE frontFace : FRONT_FACE_SEMANTIC
            #endif
            ) : SV_TARGET {
                float3 normalWS = normalize(IN.normalWS);
                #ifdef _DOUBLE_SIDED_NORMALS
	                normalWS *= IS_FRONT_VFACE(frontFace, 1, -1);
                #endif
                
                float3 viewDirWS = GetWorldSpaceNormalizeViewDir(IN.positionWS);
                float3 viewDirTS = GetViewDirectionTangentSpace(IN.tangentWS, normalWS, viewDirWS);

                float2 UV = IN.UV;
                UV += ParallaxMapping(TEXTURE2D_ARGS(_ParallaxMap, sampler_ParallaxMap), viewDirTS, _ParallaxStrength, UV);
                
                float4 textureSample = SAMPLE_TEXTURE2D(_Texture, sampler_Texture, UV);
                TestAlphaClip(textureSample);

                //Red channel - Metallic mask
                //Green channel - Smoothness mask
                float2 mask = SAMPLE_TEXTURE2D(_Mask, sampler_Mask, UV).rg;

                #ifdef _NORMALMAP
                    float3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, UV), _NormalStrength);
                    float3x3 tangentToWorld = CreateTangentToWorld(normalWS, IN.tangentWS.xyz, IN.tangentWS.w);
                    normalWS = normalize(TransformTangentToWorld(normalTS, tangentToWorld));
                #else
                    float3 normalTS = float3(0, 0, 1);
                    float3x3 tangentToWorld = float3x3(1, 0, 0, 0, 1, 0, 0, 0, 1);
                    normalWS = normalize(normalWS);
                #endif
                
	            InputData lightingInput = (InputData)0;
                lightingInput.positionWS = IN.positionWS;
                lightingInput.positionCS = IN.positionCS;
                lightingInput.normalWS = normalWS;
                lightingInput.tangentToWorld = tangentToWorld;
                lightingInput.viewDirectionWS = viewDirWS;
                lightingInput.shadowCoord = TransformWorldToShadowCoord(IN.positionWS);
                lightingInput.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.positionCS);
                lightingInput.bakedGI = SAMPLE_GI(IN.staticLightmapUV, IN.vertexSH, normalWS);;
                
	            SurfaceData surfaceInput = (SurfaceData)0;
                surfaceInput.albedo =  textureSample.rgb * _Color.rgb;
                surfaceInput.alpha = textureSample.a * _Color.a;
                surfaceInput.smoothness = mask.g * _Smoothness;
                surfaceInput.emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, UV).rgb * _EmissionColor;
                surfaceInput.normalTS = normalTS;
                surfaceInput.occlusion = 1;

                #ifdef _SPECULAR_SETUP
                    surfaceInput.specular = SAMPLE_TEXTURE2D(_SpecularMap, sampler_SpecularMap, UV).rgb * _SpecularColor;
                    surfaceInput.metallic = 0;
                #else
                    surfaceInput.specular = 1;
                    surfaceInput.metallic = mask.r * _Metallic;
                #endif
                
                return UniversalFragmentPBR(lightingInput, surfaceInput);
            }
            
            ENDHLSL
        }
        
        Pass {
            Name "ShadowCaster"
            Tags {"LightMode" = "ShadowCaster"}
            
            ColorMask 0
            
            HLSLPROGRAM
            #pragma vertex VS
            #pragma fragment PS

            #pragma shader_feature_local _ALPHA_CUTOUT
            #pragma shader_feature_local _DOUBLE_SIDED_NORMALS

            #include "Assets/Lit/ShadowCaster.hlsl"
            ENDHLSL
        }
    }
    CustomEditor "Lit.Editor.PBRInspector"
}