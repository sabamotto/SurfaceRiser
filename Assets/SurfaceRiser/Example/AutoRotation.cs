using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AutoRotation : MonoBehaviour {

    public Vector3 rotationSpeed = new Vector3(-180, 0, 0);

	// Update is called once per frame
	void Update () {
        var dt = Time.deltaTime;
        var dRotation = Quaternion.Euler(dt * rotationSpeed);
        transform.localRotation = transform.localRotation * dRotation;
	}
}
