using UnityEngine;
using System.Collections;

//Moves the progress bar based on how many ghosts we have killed
public class GhostBar : MonoBehaviour {
	
	public float numGhostsKilled = 0f;
	public int numGhosts;
    RemorseText remorse;

	//UI
	tk2dUIProgressBar bar;
	float currentValue;

	int vBar = 2;

	void Start () {
        remorse = FindObjectOfType<RemorseText>();
		numGhosts = GameObject.FindObjectsOfType<GhostAI> ().Length;
		bar = GetComponent<tk2dUIProgressBar> ();
		Reset ();
	}

	public void Reset(){
		bar.Value = 0f;
		currentValue = bar.Value;
	}
	
	// Update is called once per frame
	void FixedUpdate () {
		bar.Value = Mathf.Lerp (bar.Value, currentValue, Time.fixedDeltaTime*vBar);
	}

	//Increment bar when we have killed a ghost!
	public void KillGhost(){
		numGhostsKilled++;
        remorse.feelRemorse();
		if (numGhostsKilled > numGhosts){
			numGhostsKilled = numGhosts;
			deadState.ShowVictory();
		}
		currentValue = numGhostsKilled / numGhosts;


	}
}
