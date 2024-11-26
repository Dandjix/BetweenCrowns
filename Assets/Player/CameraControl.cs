using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraControl : MonoBehaviour
{
    [SerializeField]
    private float minSize = 5;

    [SerializeField]
    private float maxSize = 50;

    [SerializeField]
    private float increment = 1;

    // Update is called once per frame
    void Update()
    {
        float diff = Input.mouseScrollDelta.y;

        float newDim = Mathf.Clamp(Camera.main.orthographicSize + diff,minSize,maxSize);

        Camera.main.orthographicSize = newDim;

    }
}
