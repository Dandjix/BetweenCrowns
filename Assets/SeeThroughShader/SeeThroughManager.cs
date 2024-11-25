namespace SeeThrough
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;
    using UnityEngine.UIElements;
    using static UnityEditor.PlayerSettings;

    [DisallowMultipleComponent]
    public class SeeThroughManager : MonoBehaviour
    {
        public int MaxNumberOfSeeThroughObjects { get; private set; } = 5;

        public static SeeThroughManager Instance { get; private set; }

        private void Awake()
        {
            if (Instance != null)
            {
                Debug.LogWarning("you have multiple seethroughmanagers ! this is bad !");
            }
            Instance = this;
        }

        // --
        [SerializeField] private Material seeThroughMaterial;
        [SerializeField] private LayerMask mask;
        public LayerMask Mask { get => mask; }

        [SerializeField] private List<VisibleThrough> objects = new List<VisibleThrough> ();



        public bool TryAdd(VisibleThrough obj)
        {
            //Debug.Log("trying to add : " + obj);

            if(objects.Contains(obj))
                return false;

            if(objects.Count>=MaxNumberOfSeeThroughObjects)
            {
                int minPriority = int.MaxValue;
                VisibleThrough minPriorityObject = null;
                foreach (var item in objects)
                {
                    if(item.Priority < minPriority)
                    {
                        minPriority = item.Priority;
                        minPriorityObject = item;
                    }
                }

                if(minPriority>obj.Priority)
                {
                    return false;
                }

                TryRemove(minPriorityObject);
            }

            objects.Add(obj);

            Update();

            return true;
        }

        public bool TryRemove(VisibleThrough obj)
        {
            var res = objects.Remove(obj);

            Update();

            return res;
        }

        private void Update()
        {
            Vector4[] positions = new Vector4[MaxNumberOfSeeThroughObjects];
            float[] sizes = new float[MaxNumberOfSeeThroughObjects];
            float[] opacities = new float[MaxNumberOfSeeThroughObjects];
            float[] smoothnesses = new float[MaxNumberOfSeeThroughObjects];

            for (int i = 0; i < MaxNumberOfSeeThroughObjects; i++)
            {
                if (i < objects.Count)
                {
                    var obj = objects[i];

                    #if UNITY_EDITOR
                    if (obj == null || Camera.main == null) //trying to remove error
                    {
                        continue;
                    }
                    #endif

                    var view = Camera.main.WorldToViewportPoint(obj.transform.position);
                    positions[i] = view;
                    sizes[i] = obj.Visible * obj.Size;
                    smoothnesses[i] = obj.Smoothness;
                    opacities[i] = obj.Opacity;
                }
                else
                {
                    sizes[i] = 0;
                }
            }

            var posStr = "positions ("+positions.Length+") : ";
            foreach (Vector4 pos in positions)
            {
                posStr += pos.x + " : " + pos.y + "\n ";
            }
            Debug.Log(posStr);

            printFloatArray(sizes, "sizes");
            printFloatArray(opacities, "opacities");
            printFloatArray(smoothnesses, "smoothnesses");

            seeThroughMaterial.SetVectorArray("_ObjectPositions", positions);
            seeThroughMaterial.SetFloatArray("_ObjectSizes", sizes);
            seeThroughMaterial.SetFloatArray("_ObjectOpacities", opacities);
            seeThroughMaterial.SetFloatArray("_ObjectSmoothnesses", smoothnesses);
        }
        private static void printFloatArray(float[] floatArray,string title)
        {
            var str = title+" : ";
            foreach (var pos in floatArray)
            {
                str += pos+", ";
            }
            Debug.Log(str);
        }
    }

}


