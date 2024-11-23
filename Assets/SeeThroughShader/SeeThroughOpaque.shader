Shader "Custom/SeeThroughOpaque"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor("Base Color", color) = (1,1,1,1)
        _Smoothness("Smoothness", Range(0,1)) = 0
        _Metallic("Metallic", Range(0,1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalRenderPipeline" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

   #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"            


            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;
                float4 texcoord1 : TEXCOORD1;
            };

            struct Interpolators
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float3 tangentWS : TEXCOORD3;
                DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 4);
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _BaseColor;
            float _Smoothness, _Metallic;

            Interpolators vert (Attributes input)
            {
                Interpolators output;
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.normalWS = TransformObjectToWorldNormal(input.normal.xyz);
                output.tangentWS = normalize(_WorldSpaceCameraPos - output.positionWS);
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                output.positionCS = TransformWorldToHClip(output.positionWS);

                OUTPUT_LIGHTMAP_UV( input.texcoord1, unity_LightmapST, output.lightmapUV );
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH );

                return output;
            }

            half4 frag (Interpolators input) : SV_Target
            {
                //half4 col = tex2D(_MainTex, input.uv);

                InputData lightingInput = (InputData)0;
                lightingInput.positionWS = input.positionWS;
                lightingInput.normalWS = normalize(input.normalWS);
                lightingInput.viewDirectionWS = input.tangentWS;
                lightingInput.bakedGI = SAMPLE_GI( input.lightmapUV, input.vertexSH, lightingInput.normalWS );

                SurfaceData surfaceInput;
                surfaceInput.albedo = _BaseColor;
                surfaceInput.specular = 0;
                surfaceInput.metallic = _Metallic;
                surfaceInput.smoothness = _Smoothness;
                surfaceInput.normalTS = 0;
                surfaceInput.emission = 0;
                surfaceInput.occlusion = 1;
                surfaceInput.alpha = 0;
                surfaceInput.clearCoatMask = 0;
                surfaceInput.clearCoatSmoothness = 0;

                return UniversalFragmentPBR(lightingInput, surfaceInput);
            }
            ENDHLSL
        }
    }
}