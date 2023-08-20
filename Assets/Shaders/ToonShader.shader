Shader "Custom/Toon Shader" 
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        
        _ShadowColor("Shadow Color", Color) = (0, 0, 0, 1)
        _ShadowIntensity("Shadow Intensity", Range(0, 1)) = 1
        
        _SpecularColor("Spcular Color", Color) = (1, 1, 1, 1)
        _SpecularSmoothness("Specular Smoothness", Range(0, 1)) = 0
        _SpecularThreshold("Specular Threshold", Range(-1, 1)) = 0
        
        _Texture("Texture", 2D) = "white"{}
        
        _Smoothness("Smoothness", Range(0, 1)) = 0
        _Threshold("Threshold", Range(-1, 1)) = 0
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
            
            float4 _ShadowColor;
            float _ShadowIntensity;
            
            float4 _SpecularColor;
            float _SpecularSmoothness;
            float _SpecularThreshold;
            
            TEXTURE2D(_Texture);
            SAMPLER(sampler_Texture);
            float4 _Texture_ST;
            
            float _Smoothness;
            float _Threshold;
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

                const float3 position_ws = TransformObjectToWorld(IN.positionOS);
                OUT.positionWS = position_ws;
                OUT.positionCS = TransformWorldToHClip(position_ws);
                
                OUT.UV = IN.UV * _Texture_ST.xy + _Texture_ST.zw;

                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                return OUT;
            }

            float4 get_brightness(const float threshold, const float smoothness, const float n_dot_l)
            {
                const float edge1 = threshold - smoothness/2;
                const float edge2 = threshold + smoothness/2;
                return smoothstep(edge1, edge2, n_dot_l);
            }

            float4 PS (VertexOutput IN) : SV_TARGET
            {
                const float3 normal_ws = normalize(IN.normalWS);

                const Light directional_light = GetMainLight();
                const float3 view_dir = GetWorldSpaceNormalizeViewDir(IN.positionWS);
                const float3 half_vector = normalize(view_dir + directional_light.direction);

                const float brightness = get_brightness(_Threshold, _Smoothness, dot(normal_ws, directional_light.direction));
                const float light_brightness = get_brightness(_SpecularThreshold, _SpecularSmoothness, dot(half_vector, normal_ws));

                const float3 albedo_texture = SAMPLE_TEXTURE2D(_Texture, sampler_Texture, IN.UV).rgb;
                const float3 albedo =  albedo_texture * _Color.rgb;
                const float3 diffuse = lerp(lerp(albedo, _ShadowColor.xyz, _ShadowIntensity), albedo, brightness) * directional_light.color;
                const float3 specular = light_brightness * directional_light.color * _SpecularColor;
                
                return float4(diffuse + specular, 1);
            }
            
            ENDHLSL
        }
    }
}