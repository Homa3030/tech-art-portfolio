Shader "Custom/Circle Of Nth Power" 
{
    Properties
    {
        _Power("Power", float) = 1.0
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

            float _Power;

            struct VertexInput
            {
                float3 positionOS : POSITION;
                float2 UV : TEXCOORD;
                float3 normalOS : NORMAL;
            };

            struct VertexOutput
            {
                float4 positionCS : SV_POSITION;
                float2 UV : TEXCOORD;
                float3 normalWS : NORMAL;
            };

            VertexOutput VS (VertexInput IN)
            {
                VertexOutput OUT;
                
                OUT.positionCS = TransformObjectToHClip(IN.positionOS);
                OUT.UV = IN.UV;

                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                return OUT;
            }

            float4 PS (VertexOutput IN) : SV_TARGET
            {
                float2 uv = 2 * IN.UV - 1;
                float d = pow(pow(abs(uv.x), _Power) + pow(abs(uv.y), _Power), 1/_Power);
                return smoothstep(1, 0.85, d);
            }
            
            ENDHLSL
        }
    }
}