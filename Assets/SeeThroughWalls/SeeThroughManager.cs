namespace SeeThrough
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;
    using static UnityEditor.PlayerSettings;

    [DisallowMultipleComponent]
    public class SeeThroughManager : MonoBehaviour
    {
        private static readonly int maxNumberOfSeeThroughObjects
            //= 30;
            = 2;

        public static SeeThroughManager Instance { get; private set; }

        private void Awake()
        {
            if(Instance != null)
            {
                Debug.LogWarning("you have multiple seethroughmanagers ! this is bad !");

            }
            Instance = this;
            InitializeIds();
        }

        // --
        [SerializeField] private Material seeThroughMaterial;
        [SerializeField] private LayerMask mask;
        public LayerMask Mask { get => mask; }

        [SerializeField] private List<VisibleThrough> objects = new List<VisibleThrough> (maxNumberOfSeeThroughObjects);



        public bool TryAdd(VisibleThrough obj)
        {
            //Debug.Log("trying to add : " + obj);

            if(objects.Contains(obj))
                return false;

            if(objects.Count>=maxNumberOfSeeThroughObjects)
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

            UpdateObjects();

            return true;
        }

        public bool TryRemove(VisibleThrough obj)
        {
            var res = objects.Remove(obj);

            UpdateObjects();

            return res;
        }

        private void UpdateObjects()
        {

            for (int i = 0; i < maxNumberOfSeeThroughObjects; i++)
            {

                if(i<objects.Count)
                {
                    var obj = objects[i];
                    var ids = objectIds[i];

                    #if UNITY_EDITOR

                    if(obj == null) //trying to remove error
                    {
                        continue;
                    }

                    #endif

                    seeThroughMaterial.SetFloat(ids.sizeId, obj.Visible*obj.Size);
                    seeThroughMaterial.SetFloat(ids.smoothnessId, obj.Smoothness);
                    seeThroughMaterial.SetFloat(ids.opacityId, obj.Opacity);

                    var view = Camera.main.WorldToViewportPoint(obj.transform.position);
                    seeThroughMaterial.SetVector(ids.posId, view);
                }
                else
                {
                    var ids = objectIds[i];

                    seeThroughMaterial.SetFloat(ids.sizeId, 0);
                }

            }
        }

        private void Update()
        {
            for(int i = 0;i < objects.Count;i++)
            {
                var obj = objects[i];
                var ids = objectIds[i];

                var view = Camera.main.WorldToViewportPoint(obj.transform.position);
                seeThroughMaterial.SetVector(ids.posId, view);
                seeThroughMaterial.SetFloat(ids.sizeId, obj.Visible*obj.Size);
            }
        }

        private ObjectIds[] objectIds;

        private void InitializeIds()
        {
            objectIds = new ObjectIds[maxNumberOfSeeThroughObjects];

            for (int i = 0; i < maxNumberOfSeeThroughObjects; i++)
            {
                int posId = Shader.PropertyToID("_ObjectPosition_"+(i+1));
                int sizeId = Shader.PropertyToID("_Size_" + (i + 1));
                int smoothnessId = Shader.PropertyToID("_Smoothness_" + (i + 1));
                int opacityId = Shader.PropertyToID("_Opacity_" + (i + 1));

                objectIds[i] = new ObjectIds(posId, sizeId, smoothnessId, opacityId);
            }
        }

        private struct ObjectIds
        {
            public ObjectIds(int posId, int sizeId, int smoothnessId, int opacityId)
            {
                this.posId = posId;
                this.sizeId = sizeId;
                this.smoothnessId = smoothnessId;
                this.opacityId = opacityId;
            }

            public int posId;
            public int sizeId;
            public int smoothnessId;
            public int opacityId;
        }
    }
}


