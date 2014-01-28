using UnityEngine;
using System.Collections;

public class RiftManager : MonoBehaviour {

	public GameObject checkbox;
	public Texture2D checkboxTrue;
	public Texture2D checkboxFalse;

	private Resolution originalResolution;
	private bool originalFullscreen;
	private bool useRift = false;

	// Use this for initialization
	void Awake (){
		originalResolution = Screen.currentResolution;
		originalFullscreen = Screen.fullScreen;
	}
	
	// Update is called once per frame
	void Update (){
		Debug.Log(Screen.currentResolution.width);
	}

	public void OnButtonClick(){
		if(useRift){
			Screen.SetResolution(originalResolution.width, originalResolution.height, originalFullscreen);
			checkbox.renderer.material.mainTexture = checkboxFalse;
			useRift = false;
		}
		else{
			Screen.SetResolution(2*originalResolution.width, originalResolution.height, false);
			checkbox.renderer.material.mainTexture = checkboxTrue;
			useRift = true;
		}

	}

}
