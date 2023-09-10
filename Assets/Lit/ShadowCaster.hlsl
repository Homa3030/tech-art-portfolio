#ifndef SHADOW_CASTER_LIT
#define SHADOW_CASTER_LIT
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

CBUFFER_START(UnityPerMaterial)
float4 _Color;
float4 _Texture_ST;
float _Cutoff;
CBUFFER_END

#include "Assets/Lit/Common.hlsl"

struct VertexInput
{
    float3 positionOS : POSITION;
    float3 normalOS : NORMAL;

    #ifdef _ALPHA_CUTOUT
        float2 UV : TEXCOORD0;
    #endif
};

struct VertexOutput
{
    float4 positionCS : SV_POSITION;
    
    #ifdef _ALPHA_CUTOUT
        float2 UV : TEXCOORD0;
    #endif
};

float3 FlipNormalBasedOnViewDir(float3 normalWS, float3 positionWS) {
    float3 viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);
    return normalWS * (dot(normalWS, viewDirWS) < 0 ? -1 : 1);
}

float3 _LightDirection;

float4 GetShadowCasterPositionCS(float3 positionWS, float3 normalWS) {
    float3 lightDirectionWS = _LightDirection;
    #ifdef _DOUBLE_SIDED_NORMALS
        normalWS = FlipNormalBasedOnViewDir(normalWS, positionWS);
    #endif
    
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

    #ifdef _ALPHA_CUTOUT
        OUT.UV = TRANSFORM_TEX(IN.UV, _Texture);
    #endif

    OUT.positionCS = GetShadowCasterPositionCS(positionInputs.positionWS, normalInputs.normalWS);
    return OUT;
}

float4 PS(VertexOutput IN) : SV_TARGET
{
    #ifdef _ALPHA_CUTOUT
        float4 textureSample = SAMPLE_TEXTURE2D(_Texture, sampler_Texture, IN.UV);
        TestAlphaClip(textureSample);
    #endif
    return 1;
}
#endif