Shader "Custom/Blinn-Phong With Lighting And Shadows" 
{
    Properties
    {
        [Header(Surface options)]
        [MainColor] _Color("Color", Color) = (1, 1, 1, 1)
        [MainTexture] _Texture("Texture", 2D) = "white"{}
        _SpecularExponent("Specular Exponent", float) = 0
        _Smoothness("Smothness", float) = 0
    }
    Subshader
    {
        Tags {"RenderPipeline" = "UniversalPipeline" "Queue"="Transparent" "RenderType"="Transparent"}
        Pass
        {
            Name "ForwardLit"
            Tags {"LightMode" = "UniversalForward"}
            
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            HLSLPROGRAM

            #define _SPECULAR_COLOR
            
            #pragma vertex VS
            #pragma fragment PS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            TEXTURE2D(_Texture);
            SAMPLER(sampler_Texture);
            float4 _Texture_ST;
            float _SpecularExponent;
            float _Smoothness;
            CBUFFER_END
            
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
            
            float4 PS (VertexOutput IN) : SV_TARGET
            {
                float3 normalWS = normalize(IN.normalWS);
                float4 textureSample = SAMPLE_TEXTURE2D(_Texture, sampler_Texture, IN.UV);

	            InputData lightingInput = (InputData)0;
                lightingInput.positionWS = IN.positionWS;
                lightingInput.normalWS = normalWS;
                lightingInput.viewDirectionWS = GetWorldSpaceNormalizeViewDir(IN.positionWS);
                lightingInput.shadowCoord = TransformWorldToShadowCoord(IN.positionWS);
                
	            SurfaceData surfaceInput = (SurfaceData)0;
                surfaceInput.albedo =  textureSample.rgb * _Color.rgb;
                surfaceInput.alpha = textureSample.a * _Color.a;
                surfaceInput.specular = _SpecularExponent;
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

            #include "BlinnPhongShadows.hlsl"
            ENDHLSL
        }
    }
}