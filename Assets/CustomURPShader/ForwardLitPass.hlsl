#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

#include "./CustomShaderCommon.hlsl"


struct Attributes
{
    float3 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS : TANGENT;
    float2 uv : TEXCOORD0;
};

struct Interpolators
{
    float4 positionCS : SV_POSITION;

    float2 uv : TEXCOORD0;
    float3 positionWS : TEXCOORD1;
    float3 normalWS : TEXCOORD2;
    float4 tangentWS : TEXCOORD3;
};
    
Interpolators Vertex(Attributes input)
{
        Interpolators output;
        
        VertexPositionInputs posnInputs = GetVertexPositionInputs(input.positionOS);
        VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS,input.tangentOS);
    
    
        output.positionCS = posnInputs.positionCS;
        output.uv = TRANSFORM_TEX(input.uv, _ColorMap);
        output.normalWS = normalInputs.normalWS;
        output.tangentWS = float4(normalInputs.tangentWS, input.tangentOS.w);
        output.positionWS = posnInputs.positionWS;
    
        return output;
}


     
float4 Fragment(
Interpolators input 
#ifdef _DOUBLE_SIDED_NORMALS
,FRONT_FACE_TYPE frontFace : FRONT_FACE_SEMANTIC
#endif
) : SV_TARGET
{
    float2 uv = input.uv;
    float4 colorSample = SAMPLE_TEXTURE2D(_ColorMap, sampler_ColorMap, uv);
    TestAlphaClip(colorSample);
    
    float3 normalWS = normalize(input.normalWS);
    
    #ifdef _DOUBLE_SIDED_NORMALS
    normalWS  *= IS_FRONT_VFACE(frontFace, 1, -1);
    #endif
    
    InputData lightingInput = (InputData) 0;
    lightingInput.positionWS = input.positionWS;
    
    float3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uv), _NormalStrength);
    float3x3 tangentToWorld = CreateTangentToWorld(normalWS, input.tangentWS.xyz, input.tangentWS.w);
    normalWS = normalize(TransformTangentToWorld(normalTS, tangentToWorld));
    
    //return float4((normalWS + 1) * 0.5, 1); //debug
    
    lightingInput.normalWS = normalWS;
    
    lightingInput.viewDirectionWS = GetWorldSpaceNormalizeViewDir(input.positionWS);
    lightingInput.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
    lightingInput.positionCS = input.positionCS;
    lightingInput.tangentToWorld = tangentToWorld;
    
    SurfaceData surfaceInput = (SurfaceData) 0;
    surfaceInput.albedo = colorSample.rgb * _ColorTint.rgb;
    surfaceInput.alpha = colorSample.a * _ColorTint.a;
    
    #ifdef _SPECULAR_SETUP
    surfaceInput.specular = SAMPLE_TEXTURE2D(_SpecularMap, sampler_SpecularMap, uv).rgb * _SpecularTint;
    surfaceInput.metallic = 0;
    #else
    surfaceInput.specular = 1;
    surfaceInput.metallic = SAMPLE_TEXTURE2D(_MetalnessMask, sampler_MetalnessMask, uv).r * _Metalness;
    #endif
    
    float smoothnessSample = SAMPLE_TEXTURE2D(_SmoothnessMask, sampler_SmoothnessMask, uv).r * _Smoothness;
    #ifdef _ROUGHNESS_SETUP
    smoothnessSample = 1 - smoothnessSample;
    #endif
    surfaceInput.smoothness = smoothnessSample;
    surfaceInput.normalTS = normalTS;
    
    return UniversalFragmentPBR(lightingInput, surfaceInput);

}