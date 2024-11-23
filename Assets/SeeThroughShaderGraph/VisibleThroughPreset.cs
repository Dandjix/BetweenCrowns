namespace SeeThrough
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

    [CreateAssetMenu(fileName ="New Visible Through Preset", menuName ="SeeThrough/Preset")]
    public class VisibleThroughPreset : ScriptableObject
    {
        [Range(-9999, 9999)] public int Priority=0;

        [Min(0)]public float Size=1;

        [Range(0,1)]public float Opacity=1;

        [Range(0,1)]public float Smoothness=0.5f;

        [Min(0.01f)]public float timeToVisible = 0.1f;
    }

}

