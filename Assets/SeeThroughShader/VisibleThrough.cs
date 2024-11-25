namespace SeeThrough
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

    public class VisibleThrough : MonoBehaviour
    {


        //[SerializeField] private Material SeeThroughMaterial;
        //[SerializeField] private Camera Camera;
        private LayerMask Mask { get => SeeThroughManager.Instance.Mask; }

        /// <summary>
        /// the higher this is, the most it will be priviledged compared to other objects.
        /// </summary>
        //[SerializeField] [Range(-9999,9999)] private int priority = 0;
        public int Priority { get => preset.Priority; }

        //[SerializeField] private float size;
        public float Size { get => preset.Size; }
        //[SerializeField] private float opacity;
        public float Opacity { get => preset.Opacity; }
        //[SerializeField] private float smoothness;
        public float Smoothness { get => preset.Smoothness; }



        //[SerializeField] private float timeToVisible = 0.1f;

        [SerializeField] private VisibleThroughPreset preset;

        private bool isVisible = true;

        private float visible = 0;
        public float Visible
        {
            get => visible;
            private set
            {
                visible = value;
                if (visible <= 0)
                {
                    SeeThroughManager.Instance.TryRemove(this);
                }
                else
                {
                    SeeThroughManager.Instance.TryAdd(this);
                }
            }
        }

        // Update is called once per frame
        void Update()
        {
            var dir = Camera.main.transform.position - transform.position;

            var ray = new Ray(transform.position, dir.normalized);

            //Debug.Log("trying to cast ray");

            if (Physics.Raycast(ray, 1000, Mask) && isVisible)
            {
                //SeeThroughMaterial.SetFloat(sizeID, 1);
                //SeeThroughManager.Instance.TryAdd(this);
                //Debug.Log("ray hit : added");

                float newSize = Visible + Time.deltaTime / preset.timeToVisible;

                Visible = Mathf.Clamp(newSize, 0, 1);
            }
            else
            {
                //SeeThroughMaterial.SetFloat(sizeID, 0);
                //SeeThroughManager.Instance.TryRemove(this);
                //Debug.Log("ray not hit : removed");

                float newSize = Visible - Time.deltaTime / preset.timeToVisible;

                Visible = Mathf.Clamp(newSize, 0, 1);
                if(Visible <= 0 && !isVisible)
                    enabled = false;
            }

            //var view = Camera.main.WorldToViewportPoint(transform.position);

            //SeeThroughMaterial.SetVector(posID, view);
        }

        private void OnBecameInvisible()
        {
            isVisible = false;
        }

        private void OnBecameVisible()
        {
            isVisible = true;
            enabled = true;
        }
    }

}

