using UnityEngine;
using System.Collections;

public class WubGrow : MonoBehaviour {

    public float wubTime = 3f;
    public float wubSpeed = 2;
    Transform player;

	// Use this for initialization
	void Start () {
        Destroy(gameObject, wubTime);
        player = GameObject.Find("OVRPlayerController").transform;
        transform.localScale = Vector3.one * Random.value * 2;
	}
	
	// Update is called once per frame
	void Update () {
        transform.localScale += Vector3.one *  wubSpeed * Time.deltaTime;
        transform.forward = player.forward;
	}
}
