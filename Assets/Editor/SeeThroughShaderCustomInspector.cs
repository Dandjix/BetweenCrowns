using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

public class SeeThroughShaderCustomInspector : ShaderGUI
{
    public enum SurfaceType
    {
        Opaque, TransparentCutout, TransparentBlend 
    }

    public enum FaceRenderingMode
    {
        FrontOnly,
        NoCulling,
        DoubleSided
    }

    public enum BlendType
    {
        Alpha,
        Premultiplied,
        Additive,
        Multiply
    }

    public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
    {
        base.AssignNewShaderToMaterial(material, oldShader, newShader);

        //Not sure if this is necessary, since i could not replicate the issue this fixes
        if (newShader.name == "Custom/CustomShader")
        {
            UpdateSurfaceType(material);
        }
    }


    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        Material material = materialEditor.target as Material;
        var surfaceProp = BaseShaderGUI.FindProperty("_SurfaceType", properties, true);
        var blendProp = BaseShaderGUI.FindProperty("_BlendType", properties, true);
        var faceProp = BaseShaderGUI.FindProperty("_FaceRenderingMode", properties, true);
        var useClearCoatProp = BaseShaderGUI.FindProperty("_UseClearCoat", properties,true);
        var castShadowsProp = BaseShaderGUI.FindProperty("_CastShadows", properties, true);

        EditorGUI.BeginChangeCheck();
        surfaceProp.floatValue = (int)(SurfaceType)EditorGUILayout.EnumPopup("Surface type", (SurfaceType)surfaceProp.floatValue);
        blendProp.floatValue = (int)(BlendType)EditorGUILayout.EnumPopup("Blend mode",(BlendType)blendProp.floatValue);
        faceProp.floatValue = (int)(FaceRenderingMode)EditorGUILayout.EnumPopup("Face rendering mode", (FaceRenderingMode)faceProp.floatValue);
        useClearCoatProp.floatValue = EditorGUILayout.Toggle("Use clear coat", useClearCoatProp.floatValue == 1) ? 1 : 0;
        castShadowsProp.floatValue = EditorGUILayout.Toggle("Cast shadows", castShadowsProp.floatValue == 1) ? 1 : 0;
        if (EditorGUI.EndChangeCheck())
        {
            UpdateSurfaceType(material);
        }

        base.OnGUI(materialEditor, properties);
    }

    private void UpdateSurfaceType(Material material)
    {
        SurfaceType surface = (SurfaceType)material.GetFloat("_SurfaceType");
        BlendType blend = (BlendType)material.GetFloat("_BlendType");
        switch (surface)
        {
            case SurfaceType.Opaque:
                material.renderQueue = (int)RenderQueue.Geometry;
                material.SetOverrideTag("RenderType", "Opaque");
                break;
            case SurfaceType.TransparentCutout:
                material.renderQueue = (int)RenderQueue.AlphaTest;
                material.SetOverrideTag("RenderType", "TransparentCutout");
                break;
            case SurfaceType.TransparentBlend:
                material.renderQueue = (int)RenderQueue.Transparent;
                material.SetOverrideTag("RenderType", "Transparent");
                break;

        }

        switch (surface)
        {
            case SurfaceType.Opaque:
            case SurfaceType.TransparentCutout:
                material.SetInt("_SourceBlend",(int)BlendMode.One);
                material.SetInt("_DestBlend",(int)BlendMode.Zero);
                material.SetInt("_ZWrite", 1);

                break;
            case SurfaceType.TransparentBlend:
                switch (blend)
                {
                    case BlendType.Alpha:
                        material.SetInt("_SourceBlend", (int)BlendMode.SrcAlpha);
                        material.SetInt("_DestBlend", (int)BlendMode.OneMinusSrcAlpha);
                        break;
                    case BlendType.Premultiplied:
                        material.SetInt("_SourceBlend", (int)BlendMode.One);
                        material.SetInt("_DestBlend", (int)BlendMode.OneMinusSrcAlpha);
                        break;
                    case BlendType.Additive:
                        material.SetInt("_SourceBlend", (int)BlendMode.SrcAlpha);
                        material.SetInt("_DestBlend", (int)BlendMode.One);
                        break;
                    case BlendType.Multiply:
                        material.SetInt("_SourceBlend", (int)BlendMode.Zero);
                        material.SetInt("_DestBlend", (int)BlendMode.OneMinusSrcAlpha);
                        break;
                }
                material.SetInt("_ZWrite", 0);
                break;
        }

        bool castShadows = material.GetFloat("_CastShadows")==1;
        material.SetShaderPassEnabled("ShadowCaster", castShadows);

        if(surface == SurfaceType.TransparentCutout)
        {
            material.EnableKeyword("_ALPHA_CUTOUT");
        }
        else
        {
            material.DisableKeyword("_ALPHA_CUTOUT");
        }

        if (surface == SurfaceType.TransparentBlend && blend == BlendType.Premultiplied)
        {
            material.EnableKeyword("_ALPHAPREMULTIPLY_ON");
        }
        else
        {
            material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
        }

        FaceRenderingMode faceRenderingMode = (FaceRenderingMode)material.GetFloat("_FaceRenderingMode");
        if (faceRenderingMode == FaceRenderingMode.FrontOnly)
        {
            material.SetFloat("_Cull", (int)UnityEngine.Rendering.CullMode.Back);
        }
        else
        {
            material.SetFloat("_Cull", (int)UnityEngine.Rendering.CullMode.Off);
        }

        if (faceRenderingMode == FaceRenderingMode.DoubleSided)
        {
            material.EnableKeyword("_DOUBLE_SIDED_NORMALS");
        }
        else
        {
            material.DisableKeyword("_DOUBLE_SIDED_NORMALS");
        }

        bool useClearCoat = material.GetFloat("_UseClearCoat") == 1;
        if (useClearCoat)
        {
            material.EnableKeyword("_CLEARCOATMAP");
        }
        else
        {
            material.DisableKeyword("_CLEARCOATMAP");
        }
    }
}