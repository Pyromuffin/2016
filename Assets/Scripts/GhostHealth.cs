using UnityEngine;
using System.Collections;

public class GhostHealth : MonoBehaviour {

	public GameObject deathParticle;
    GhostBar theBar;
    public Animator animator;
    GhostAI ai;
	// Use this for initialization
	void Start () {
        ai = GetComponent<GhostAI>();
        theBar = FindObjectOfType<GhostBar>();
	}
	
	// Update is called once per frame
	void Update () {
	
	}

	public void TeddyAttack(){
		Debug.Log("Teddy Attack on ghost.");
        animator.SetTrigger("die");
        ai.state = GhostAI.ghostState.dead;
		Destroy(Instantiate(deathParticle,transform.position,Quaternion.identity),5);
        theBar.KillGhost();
        Destroy(gameObject, 2);

	}
}
