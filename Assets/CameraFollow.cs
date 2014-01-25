using UnityEngine;
using System.Collections;

public class CameraFollow : MonoBehaviour {
    public Transform followTarget;
    public float viewAngle = 60;
    public float followDistance = 5;

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
        transform.position = followTarget.position;
        transform.forward = followTarget.forward;
        transform.Rotate(new Vector3(viewAngle, 0, 0));
        transform.position -= transform.forward * followDistance;
	}
}
