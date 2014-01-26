using UnityEngine;
using System.Collections;

public class GhostHealth : MonoBehaviour {

	public GameObject deathParticle;

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}

	public void TeddyAttack(){
		Debug.Log("Teddy Attack on ghost.");
		Destroy(Instantiate(deathParticle,transform.position,Quaternion.identity),5);
		Destroy(gameObject);
	}
}
