#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

#include "./CustomShaderCommon.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ParallaxMapping.hlsl"

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
    
    DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 4);
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
    
        OUTPUT_LIGHTMAP_UV(input.texcoord1, unity_LightmapST, output.lightmapUV);
        OUTPUT_SH(output.normalWS.xyz, output.vertexSH);
    
        return output;
}


     
float4 Fragment(
Interpolators input 
#ifdef _DOUBLE_SIDED_NORMALS
,FRONT_FACE_TYPE frontFace : FRONT_FACE_SEMANTIC
#endif
) : SV_TARGET
{    

    
    float3 normalWS = input.normalWS;
   
    
    #ifdef _DOUBLE_SIDED_NORMALS
    normalWS  *= IS_FRONT_VFACE(frontFace, 1, -1);
    #endif
    
    float3 positionWS = input.positionWS;
    float3 viewDirectionWS = GetWorldSpaceNormalizeViewDir(positionWS);
    float3 viewDirectionTS = GetViewDirectionTangentSpace(input.tangentWS, normalWS, viewDirectionWS);
    
    
    float2 uv = input.uv;
    uv += ParallaxMapping(TEXTURE2D_ARGS(_ParallaxMap, sampler_ParallaxMap), viewDirectionTS, _ParallaxStrength, uv);
    
    float4 colorSample = SAMPLE_TEXTURE2D(_ColorMap, sampler_ColorMap, uv);
    TestAlphaClip(colorSample);
    
    float3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uv), _NormalStrength);
    float3x3 tangentToWorld = CreateTangentToWorld(normalWS, input.tangentWS.xyz, input.tangentWS.w);
    normalWS = normalize(TransformTangentToWorld(normalTS, tangentToWorld));
    
    InputData lightingInput = (InputData) 0;
    lightingInput.positionWS = positionWS;
    
    //return float4((normalWS + 1) * 0.5, 1); //debug
    //return SAMPLE_TEXTURE2D(_ClearCoatMask, sampler_ClearCoatMask, uv).r * _ClearCoatSrength;
    
    lightingInput.normalWS = normalWS;
    
    lightingInput.viewDirectionWS = viewDirectionWS;
    lightingInput.shadowCoord = TransformWorldToShadowCoord(positionWS);
    lightingInput.positionCS = input.positionCS;
    lightingInput.tangentToWorld = tangentToWorld;
    lightingInput.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, lightingInput.normalWS);

    
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
    surfaceInput.emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uv).rgb * _EmissionTint;
    #ifdef _CLEARCOATMAP
    surfaceInput.clearCoatMask = SAMPLE_TEXTURE2D(_ClearCoatMask, sampler_ClearCoatMask, uv).r * _ClearCoatStrength;
    surfaceInput.clearCoatSmoothness = SAMPLE_TEXTURE2D(_ClearCoatSmoothnessMask, sampler_ClearCoatSmoothnessMask, uv).r * _ClearCoatSmoothness;
    #endif
    surfaceInput.normalTS = normalTS;
    
    surfaceInput.occlusion = 1;
    
    return UniversalFragmentPBR(lightingInput, surfaceInput);

}