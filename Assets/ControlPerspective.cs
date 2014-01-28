using UnityEngine;
using System.Collections;

public class ControlPerspective : MonoBehaviour {

	public string buttonName = "Jump";
	public GameObject firstPersonCam;
	public GameObject thirdPersonCam;

	private bool inFirstPerson = true;

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
		if(Input.GetButtonUp(buttonName)){
			if(inFirstPerson){
				//Switch to third person
				firstPersonCam.GetComponent<Camera>().enabled = false;
				thirdPersonCam.GetComponent<Camera>().enabled = true;
				inFirstPerson = false;
			}
			else{
				//Switch to first person
				firstPersonCam.GetComponent<Camera>().enabled = true;
				thirdPersonCam.GetComponent<Camera>().enabled = false;
				inFirstPerson = true;
			}
		}
	}
}
