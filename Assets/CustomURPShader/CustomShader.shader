Shader "Custom/CustomShader"
{
    Properties
    {
        [Header(Surface options)]
        [MainTexture] _ColorMap("Color",2D) = "white" {}
        [MainColor] _ColorTint("Tint",Color) = (1,1,1,1)
        _Smoothness("Smoothness",float) = 0
        _Cutoff("Cutout threshold",Range(0,1)) = 0.5

        [HideInInspector] _SourceBlend("Source blend", float) = 0
        [HideInInspector] _DestBlend("Destination blend", float) = 0
        [HideInInspector] _ZWrite("Zwrite", float) = 0

        [HideInInspector] _SurfaceType("Surface type", float) = 0
    }


    SubShader
    {

        Tags { "RenderPipeline"="UniversalPipeline" "RenderType" = "Opaque"}

        Pass
        {
            Name "ForwardLit"
            Tags{"LightMode" = "UniversalForward"}

            Blend [_SourceBlend] [_DestBlend]
            ZWrite [_ZWrite]

            ColorMask RGBA

            HLSLPROGRAM

            #define _SPECULAR_COLOR

            #pragma shader_feature_local _ALPHA_CUTOUT

            // #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            //TODO : check if the above code works now
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE

            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "ForwardLitPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags {"LightMode" = "ShadowCaster"}

            ColorMask 0

            HLSLPROGRAM

            #pragma shader_feature_local _ALPHA_CUTOUT

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "ShadowCasterPass.hlsl"
            ENDHLSL
        }
     }
    CustomEditor "CustomShaderCustomInspector"
}
