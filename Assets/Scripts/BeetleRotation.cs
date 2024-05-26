using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BeetleRotation : MonoBehaviour
{
    public float rotationSpeed = 40f;

    // Update is called once per frame
    void Update()
    {
        transform.Rotate(Vector3.forward * (Time.deltaTime * rotationSpeed));
    }
}
