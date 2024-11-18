Shader "Custom/SeeThrough_N"
{
    Properties
    {
        [Header(Surface options)]
        [MainTexture] _ColorMap("Color",2D) = "white" {}
        [MainColor] _ColorTint("Tint",Color) = (1,1,1,1)
    }


    SubShader
    {

        Tags { "RenderPipeline"="UniversalPipeline" }

        Pass
        {
            Name "ZiziLit"
            Tags{"LightMode" = "UniversalForward"}

            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "SeeThrough_N.hlsl"
            ENDHLSL
        }
    }
}
