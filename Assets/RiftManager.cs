using UnityEngine;
using System.Collections;

public class RiftManager : MonoBehaviour {

	//The reference to the singleton (the only instantiation)
	private static RiftManager instance;
	public static RiftManager Instance{
		get {return instance;}
	}

	private Resolution originalResolution;
	private bool originalFullscreen;
	private bool useRift = false;

	// Use this for initialization
	void Awake (){

		//Stuff to make this a singleton, i.e. only one instance ever occurs at any time
		if(instance != null && instance != this){
			Destroy(gameObject);
			return;
		}
		else{
			instance = this;
		}

		//Make sure that the object doesn't go away
		DontDestroyOnLoad(gameObject);

		originalResolution = Screen.currentResolution;
		originalFullscreen = Screen.fullScreen;
	}

	// Update is called once per frame
	void Update (){
	}

	public GameObject checkbox;
	public Texture2D checkboxTrue;
	public Texture2D checkboxFalse;

	public void OnButtonClick(){
		if(useRift){
			Screen.SetResolution(originalResolution.width, originalResolution.height, originalFullscreen);
			checkbox.renderer.material.mainTexture = checkboxFalse;
			ActivateRift();
		}
		else{
			Screen.SetResolution(2*originalResolution.width, originalResolution.height, false);
			checkbox.renderer.material.mainTexture = checkboxTrue;
			DeactivateRift();
		}

	}

	public GameObject OVRController;

	public GameObject normalController;

	private void ActivateRift(){

		useRift = true;
	}

	private void DeactivateRift(){
		OVRController.SetActive(false);
		useRift = false;
	}

}
