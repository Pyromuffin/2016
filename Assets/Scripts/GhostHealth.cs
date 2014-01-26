using UnityEngine;
using System.Collections;

public class GhostHealth : MonoBehaviour {

	public GameObject deathParticle;
    GhostBar theBar;

	// Use this for initialization
	void Start () {
        theBar = FindObjectOfType<GhostBar>();
	}
	
	// Update is called once per frame
	void Update () {
	
	}

	public void TeddyAttack(){
		Debug.Log("Teddy Attack on ghost.");
		Destroy(Instantiate(deathParticle,transform.position,Quaternion.identity),5);
        theBar.KillGhost();
        Destroy(gameObject);

	}
}
