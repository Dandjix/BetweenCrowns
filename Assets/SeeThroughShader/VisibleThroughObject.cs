namespace SeeThrough
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

    [DisallowMultipleComponent]
    [RequireComponent(typeof(VisibleThrough))]
    public class VisibleThroughObject : MonoBehaviour
    {
        private VisibleThrough visibleThrough;

        private void Start()
        {
            visibleThrough = GetComponent<VisibleThrough>();
        }

        private bool isVisible = true;

        void Update()
        {
            var dir = Camera.main.transform.position - transform.position;

            var ray = new Ray(transform.position, dir.normalized);

            if (Physics.Raycast(ray, 1000, visibleThrough.Mask) && isVisible)
            {
                float newSize =visibleThrough.Visible + Time.deltaTime / visibleThrough.TimeToVisible;

                visibleThrough.Visible = Mathf.Clamp(newSize, 0, 1);
            }
            else
            {
                float newSize = visibleThrough.Visible - Time.deltaTime / visibleThrough.TimeToVisible;

                visibleThrough.Visible = Mathf.Clamp(newSize, 0, 1);
                if (visibleThrough.Visible <= 0 && !isVisible)
                    enabled = false;
            }
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

        private void OnDisable()
        {
            if (visibleThrough.Visible <= 0 || !gameObject.scene.isLoaded)
                return;

            GameObject trace = new GameObject("VisibleThroughTrace");
            trace.transform.position = transform.position;

            VisibleThrough visibleThrough_OfTrace = trace.AddComponent<VisibleThrough>();
            visibleThrough_OfTrace.Preset = visibleThrough.Preset;
            visibleThrough_OfTrace.Visible = visibleThrough.Visible;

            trace.AddComponent<VisibleThroughTrace>();
            trace.gameObject.layer = gameObject.layer;


        }
    }

}

