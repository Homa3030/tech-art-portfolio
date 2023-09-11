Shader "Custom/Blinn-Phong With Shadows And Transparency" 
{
    Properties
    {
        [Header(Surface options)]
        [MainColor] _Color("Color", Color) = (1, 1, 1, 1)
        [MainTexture] _Texture("Texture", 2D) = "white"{}
        _Cutoff("Aplha cutout threshold", Range(0, 1)) = 0.5
        _SpecularExponent("Specular Exponent", float) = 0
        _Smoothness("Smothness", float) = 0
        
        [HideInInspector] _Cull("Cull Mode", float) = 2
        [HideInInspector] _SourceBlend("Source blend", Float) = 0
        [HideInInspector] _DestBlend("Destination blend", Float) = 0
        [HideInInspector] _ZWrite("ZWrite", Float) = 0
        
        [HideInInspector] _SurfaceType("Surface type", Float) = 0
        [HideInInspector] _FaceRenderingMode("Face rendering type", Float) = 0
    }
    Subshader
    {
        Tags {"RenderPipeline" = "UniversalPipeline" "RenderType"="Opaque"}
        Pass
        {
            Name "ForwardLit"
            Tags {"LightMode" = "UniversalForward"}
            
            Blend [_SourceBlend][_DestBlend]
            ZWrite[_ZWrite]
            Cull[_Cull]
            
            HLSLPROGRAM

            #define _SPECULAR_COLOR

            #pragma shader_feature_local _ALPHA_CUTOUT
            #pragma shader_feature_local _DOUBLE_SIDED_NORMALS
            
            #pragma vertex VS
            #pragma fragment PS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float4 _Texture_ST;
            float4 _SpecularColor;
            float _Cutoff;
            float _Smoothness;
            CBUFFER_END

            #include "Assets/Lit/Common.hlsl"
            
            struct VertexInput
            {
                float3 positionOS : POSITION;
                float2 UV : TEXCOORD;
                float3 normalOS : NORMAL;
            };

            struct VertexOutput
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : POSITION_WS;
                float2 UV : TEXCOORD;
                float3 normalWS : NORMAL;
            };

            VertexOutput VS (VertexInput IN)
            {
                VertexOutput OUT;
                
                OUT.positionCS = TransformObjectToHClip(IN.positionOS);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS);
                
                OUT.UV = IN.UV * _Texture_ST.xy + _Texture_ST.zw;

                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
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
                
                float4 textureSample = SAMPLE_TEXTURE2D(_Texture, sampler_Texture, IN.UV);
                TestAlphaClip(textureSample);

	            InputData lightingInput = (InputData)0;
                lightingInput.positionWS = IN.positionWS;
                lightingInput.normalWS = normalWS;
                lightingInput.viewDirectionWS = GetWorldSpaceNormalizeViewDir(IN.positionWS);
                lightingInput.shadowCoord = TransformWorldToShadowCoord(IN.positionWS);
                
	            SurfaceData surfaceInput = (SurfaceData)0;
                surfaceInput.albedo =  textureSample.rgb * _Color.rgb;
                surfaceInput.alpha = textureSample.a * _Color.a;
                surfaceInput.smoothness = _Smoothness;
                
                return UniversalFragmentBlinnPhong(lightingInput, surfaceInput);
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
    CustomEditor "Lit.Editor.BlinnPhongInspector"
}