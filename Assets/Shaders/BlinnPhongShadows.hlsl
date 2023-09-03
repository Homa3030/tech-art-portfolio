#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct VertexInput
{
    float3 positionOS : POSITION;
    float3 normalOS : NORMAL;
};

struct VertexOutput
{
    float4 positionCS : SV_POSITION;
};

float3 _LightDirection;

float4 GetShadowCasterPositionCS(float3 positionWS, float3 normalWS) {
    float3 lightDirectionWS = _LightDirection;
    float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));
#if UNITY_REVERSED_Z
    positionCS.z = min(positionCS.z, UNITY_NEAR_CLIP_VALUE);
#else
    positionCS.z = max(positionCS.z, UNITY_NEAR_CLIP_VALUE);
#endif
    return positionCS;
}

VertexOutput VS(VertexInput IN)
{
    VertexOutput OUT;

    VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS);
    VertexNormalInputs normalInputs = GetVertexNormalInputs(IN.normalOS);

    OUT.positionCS = GetShadowCasterPositionCS(positionInputs.positionWS, normalInputs.normalWS);
    return OUT;
}

float4 PS(VertexOutput IN) : SV_TARGET
{
    return 1;
}
