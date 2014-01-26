using UnityEngine;
using System.Collections;

public class TeddyCharging : MonoBehaviour {

	public float chargeLevel = 0.0f;

	private Vector3 originalScale;

	// Use this for initialization
	void Start () {
		originalScale = transform.localScale;
	}
	
	// Update is called once per frame
	void Update () {
		//Go from black to white as it charges
		renderer.material.color = Color.Lerp(Color.black, Color.white, chargeLevel);
		//Go from full scale, to 40% scale as it charges
		transform.localScale = originalScale * Mathf.Lerp(1.0f, 0.4f, chargeLevel);
	}
}
