namespace Player
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

    public class CameraFollower : MonoBehaviour
    {
        [SerializeField] private Transform PlayerTransform;
        private Vector3 offsetPosition;
        //private Quaternion offsetRotation;

        private void Start()
        {
            offsetPosition = transform.localPosition;
            //offsetRotation = transform.localRotation;
            transform.parent = null;
        }

        // Update is called once per frame
        void Update()
        {
            transform.position = offsetPosition + PlayerTransform.position;
            //transform.rotation = offsetRotation;
        }
    }

}

