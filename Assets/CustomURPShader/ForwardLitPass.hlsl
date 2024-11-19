#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

#include "./CustomShaderCommon.hlsl"


struct Attributes
{
    float3 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 uv : TEXCOORD0;
};

struct Interpolators
{
    float4 positionCS : SV_POSITION;

    float2 uv : TEXCOORD0;
    float3 positionWS : TEXCOORD1;
    float3 normalWS : TEXCOORD2;
};
    
Interpolators Vertex(Attributes input)
{
        Interpolators output;
        
        VertexPositionInputs posnInputs = GetVertexPositionInputs(input.positionOS);
        VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS);
    
    
        output.positionCS = posnInputs.positionCS;
        output.uv = TRANSFORM_TEX(input.uv, _ColorMap);
        output.normalWS = normalInputs.normalWS;
        output.positionWS = posnInputs.positionWS;
    
        return output;
}


     
float4 Fragment(Interpolators input) : SV_TARGET
{
    float2 uv = input.uv;
    float4 colorSample = SAMPLE_TEXTURE2D(_ColorMap, sampler_ColorMap, uv);
    
    TestAlphaClip(colorSample);
    
    InputData lightingInput = (InputData) 0;
    lightingInput.positionWS = input.positionWS;
    lightingInput.normalWS = normalize(input.normalWS);
    lightingInput.viewDirectionWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
    lightingInput.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
    
    SurfaceData surfaceInput = (SurfaceData) 0;
    surfaceInput.albedo = colorSample.rgb * _ColorTint.rgb;
    surfaceInput.alpha = colorSample.a * _ColorTint.a;
    surfaceInput.specular = 1;
    surfaceInput.smoothness = _Smoothness;
    
    return UniversalFragmentBlinnPhong(lightingInput, surfaceInput);

}