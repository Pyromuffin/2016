using UnityEngine;
using System.Collections;

public class GhostBeeping : MonoBehaviour {
    public float beepRate = .5f;
	// Use this for initialization
	void Start () {
        InvokeRepeating("beep", 0, .5f);
	}


    public void beep()
    {
        audio.Play();
    }

	// Update is called once per frame
	void Update () {
	    

	}
}
