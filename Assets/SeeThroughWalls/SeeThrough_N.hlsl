#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

float4 _ColorTint;

TEXTURE2D(_ColorMap); SAMPLER(sampler_ColorMap);
float4 _ColorMap_ST;


struct Attributes
{
    float3 positionOS : POSITION;
    float2 uv : TEXCOORD0;
};

struct Interpolators
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
};
    
Interpolators Vertex(Attributes input)
{
        Interpolators output;
        
        VertexPositionInputs posnInputs = GetVertexPositionInputs(input.positionOS);
    
        output.positionCS = posnInputs.positionCS;
        output.uv = TRANSFORM_TEX(input.uv, _ColorMap);
        
        return output;
}
     
float4 Fragment(Interpolators input) : SV_TARGET
{
    float2 uv = input.uv;
    
    float4 colorSample = SAMPLE_TEXTURE2D(_ColorMap, sampler_ColorMap, uv);
    return colorSample * _ColorTint;
}