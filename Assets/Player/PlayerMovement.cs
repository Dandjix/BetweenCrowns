namespace Player
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

    public class PlayerMovement : MonoBehaviour
    {
        [SerializeField]
        private new Rigidbody rigidbody;

        [SerializeField]
        private float movementSpeed = 10;

        void Update()
        {
            var input = getInput();

            rigidbody.velocity = new Vector3(input.x, rigidbody.velocity.y, input.y)* movementSpeed;
            //rigidbody.velocity = new Vector3(input.x, 0, input.y)* movementSpeed;
        }

        private Vector2 getInput()
        {
            float xInput = 0;
            float yInput = 0;

            if (Input.GetKey(KeyCode.RightArrow))
            {
                xInput = 1;
            }
            if (Input.GetKey(KeyCode.LeftArrow))
            {
                xInput -= 1;
            }

            if (Input.GetKey(KeyCode.UpArrow))
            {
                yInput += 1;
            }
            if (Input.GetKey(KeyCode.DownArrow))
            {
                yInput -= 1;
            }

            return new Vector2(xInput, yInput);
        }
    }
}
