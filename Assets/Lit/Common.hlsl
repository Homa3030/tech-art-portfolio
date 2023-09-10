#ifndef COMMON_LIT
#define COMMON_LIT
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

TEXTURE2D(_Texture); SAMPLER(sampler_Texture);

void TestAlphaClip(float4 textureSample) {
    #ifdef _ALPHA_CUTOUT
        clip(textureSample.a * _Color.a - _Cutoff);
    #endif
}
#endif
