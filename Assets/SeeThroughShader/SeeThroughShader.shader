Shader "Custom/SeeThrough/Opaque"
{
    Properties
    {
        [Header(Surface options)]
        [MainTexture] _ColorMap("Color",2D) = "white" {}
        [MainColor] _ColorTint("Tint",Color) = (1,1,1,1)
        _Cutoff("Cutout threshold",Range(0,1)) = 0.5

        [Toggle(_CASTS_SHADOWS)] _CastsShadows("Casts shadows",float) = 0

        [NoScaleOffset][Normal] _NormalMap("Normal", 2D) = "bump" {}
        _NormalStrength("Normal strength",Range(0,1)) = 1

        [NoScaleOffset] _MetalnessMask("Metalness mask",2D) = "black" {}
        _Metalness("Metalness",Range(0,1)) = 0

        [Toggle(_SPECULAR_SETUP)] _SpecularSetupToggle("Use specular workflow",float) = 0
        [NoScaleOffset] _SpecularMap("Specular map",2D) = "white" {}
        _SpecularTint("Specular tint",Color) = (1,1,1,1)

        [Toggle(_ROUGHNESS_SETUP)] _RoughnessSetupToggle("Use roughness instead of smoothness",float) = 0
        [NoScaleOffset] _SmoothnessMask("Smoothness mask",2D) = "white" {}
        _Smoothness("Smoothness",Range(0,1)) = 0.5

        [NoScaleOffset] _EmissionMap("Emmision map",2D) = "white" {}
        [HDR] _EmissionTint("Emission tint",Color) = (1,1,1,1) 

        [NoScaleOffset] _ParallaxMap("Parallax map",2D) = "white" {}
        _ParallaxStrength("Parallax strength",Range(0,1)) = 0

        [NoScaleOffset] _ClearCoatMask("Clear coat mask", 2D) = "white" {}
        _ClearCoatStrength("Clear coat strength", Range(0,1)) = 0
        [NoScaleOffset] _ClearCoatSmoothnessMask("Clear coat smoothness mask", 2D) = "white" {}
        _ClearCoatSmoothness("Clear coat Smoothness", Range(0,1)) = 0

        [HideInInspector] _Cull("Cull mode", float) = 2

        [HideInInspector] _SourceBlend("Source blend", float) = 0
        [HideInInspector] _DestBlend("Destination blend", float) = 0
        [HideInInspector] _ZWrite("Zwrite", float) = 0

        [HideInInspector] _SurfaceType("Surface type", float) = 0
        [HideInInspector] _BlendType("Blend type", float) = 0
        [HideInInspector] _FaceRenderingMode("Face rendering type", float) = 0

        [HideInInspector] _UseClearCoat("Use clear coat",float) = 0

        [HideInInspector] _CastShadows("Cast shadows",float) = 0
    }


    SubShader
    {
        Tags { "RenderPipeline"="UniversalRenderPipeline" "RenderType" = "Opaque"}

        Pass
        {
            Name "ForwardLit"
            Tags{"LightMode" = "UniversalForward"}

            Blend [_SourceBlend] [_DestBlend]
            ZWrite [_ZWrite]
            Cull[_Cull]

            ColorMask RGBA

            HLSLPROGRAM

            #define _NORMALMAP
            #define _SPECULAR_COLOR

            #pragma shader_feature_local _ALPHA_CUTOUT
            #pragma shader_feature_local _DOUBLE_SIDED_NORMALS
            #pragma shader_feature_local _CASTS_SHADOWS

            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local_fragment _ROUGHNESS_SETUP
            #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local_fragment _CLEARCOATMAP


            // #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            //TODO : check if the above code works now
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE

            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            #pragma vertex Vertex
            #pragma fragment Fragment

            #pragma MAX_OBJECTS_150
            #pragma MAX_OBJECTS_50
            #pragma MAX_OBJECTS_15

            #pragma multi_compile _ MAX_OBJECTS_150 MAX_OBJECTS_50 MAX_OBJECTS_15

            #ifdef MAX_OBJECTS_150
                #define MAX_OBJECTS 150
            #elif defined(MAX_OBJECTS_50)
                #define MAX_OBJECTS 50
            #elif defined(MAX_OBJECTS_15)
                #define MAX_OBJECTS 15
            #else
                #define MAX_OBJECTS 5
            #endif

            float2 _ObjectPositions[MAX_OBJECTS];
            float _ObjectSizes[MAX_OBJECTS];    
            float _ObjectOpacities[MAX_OBJECTS];  
            float _ObjectSmoothnesses[MAX_OBJECTS]; 

            #include "ForwardLitPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags {"LightMode" = "ShadowCaster"}

            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM

            #pragma shader_feature_local _ALPHA_CUTOUT
            #pragma shader_feature_local _DOUBLE_SIDED_NORMALS

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "ShadowCasterPass.hlsl"
            ENDHLSL
        }
     }
    CustomEditor "SeeThroughShaderCustomInspector"
}
