using UnityEngine;
using System.Collections;

//Moves the progress bar based on how many ghosts we have killed
public class GhostBar : MonoBehaviour {
	
	int numGhostsKilled = 0;
	public int numGhosts;
    RemorseText remorse;
    public GameObject dsGO;
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
		if (numGhostsKilled >= numGhosts){
            dsGO.SetActive(true);
            FindObjectOfType<OVRCameraController>().enabled = false;
			deadState.ShowVictory();
		}
		currentValue = numGhostsKilled / numGhosts;


	}
}
