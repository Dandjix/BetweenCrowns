using SeeThrough;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.Presets;
using UnityEngine;
using UnityEngine.UI;

[DisallowMultipleComponent]
[RequireComponent(typeof(VisibleThrough))]
public class VisibleThroughTrace : MonoBehaviour
{
    private VisibleThrough visibleThrough;

    private void Start()
    {
        visibleThrough = GetComponent<VisibleThrough>();
    }

    void Update()
    {
        var dir = Camera.main.transform.position - transform.position;

        var ray = new Ray(transform.position, dir.normalized);

        float newSize = visibleThrough.Visible - Time.deltaTime / visibleThrough.TimeToVisible;

        visibleThrough.Visible = Mathf.Clamp(newSize, 0, 1);

        if(visibleThrough.Visible <= 0 )
        {
            Destroy(gameObject);
        }
    }
}
