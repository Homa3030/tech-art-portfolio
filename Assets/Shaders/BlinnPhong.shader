Shader "Custom/Blinn-Phong" 
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _Texture("Texture", 2D) = "white"{}
        _SpecularExponent("Specular Exponent", float) = 5
    }
    Subshader
    {
        Pass
        {
            HLSLPROGRAM
            
            #pragma vertex VS
            #pragma fragment PS
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            TEXTURE2D(_Texture);
            SAMPLER(sampler_Texture);
            float4 _Texture_ST;
            float _SpecularExponent;
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
                
                Light directionalLight = GetMainLight();
                float3 viewDir = GetWorldSpaceNormalizeViewDir(IN.positionWS);
                float3 halfVector = normalize(viewDir + directionalLight.direction);
                
                float3 albedoTexture = SAMPLE_TEXTURE2D(_Texture, sampler_Texture, IN.UV).rgb;
                float3 albedo =  albedoTexture * _Color.rgb;
                float3 diffuse = saturate(dot(normalWS, directionalLight.direction)) * directionalLight.color;
                float3 specular = pow(saturate(dot(halfVector, normalWS)), _SpecularExponent) * directionalLight.color;
                
                return float4(albedo * diffuse + specular, 1);
            }
            
            ENDHLSL
        }
    }
}