using UnityEngine;
using System.Collections;

public class PlayerControllerManager : MonoBehaviour {

	public GameObject occulusPrefab;
	public GameObject normalPrefab;

	// Use this for initialization
	void Awake () {
		GameObject riftMgr = GameObject.Find("$RiftManager");

		if(riftMgr != null){
			//If we're using the occulus, instantiate the OVR character controller
			if(riftMgr.GetComponent<RiftManager>().UseRift){
				Instantiate(occulusPrefab,transform.position,Quaternion.identity);
			}
			//Otherwise, instantiate the standard charactar controller
			else{
				Instantiate(normalPrefab,transform.position,Quaternion.identity);
			}
		}
		else{ //If the rift manager is null
			Debug.Log ("The RiftManager could not be found.");
			Instantiate(normalPrefab,transform.position,Quaternion.identity);
		}

	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
