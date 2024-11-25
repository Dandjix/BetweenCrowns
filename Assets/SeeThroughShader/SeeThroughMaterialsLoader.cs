using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public static class SeeThroughMaterialsLoader
{
    public static Material[] load()
    {
        Material[] materials = Resources.LoadAll<Material>("SeeThroughMaterials");
        return materials;
    }
}
