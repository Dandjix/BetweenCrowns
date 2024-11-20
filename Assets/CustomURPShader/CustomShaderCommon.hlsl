#ifndef CUSTOM_SHADER_COMMON_INCLUDED
#define CUSTOM_SHADER_COMMON_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"



TEXTURE2D(_ColorMap); SAMPLER(sampler_ColorMap);
TEXTURE2D(_NormalMap); SAMPLER(sampler_NormalMap);

float4 _ColorMap_ST;
float4 _ColorTint;
float _Cutoff;
float _Smoothness;
float _NormalStrength;

void TestAlphaClip(float4 colorSample)
{
    #if defined(_ALPHA_CUTOUT)
    clip(colorSample.a * _ColorTint.a - _Cutoff);
    #endif
}

#endif