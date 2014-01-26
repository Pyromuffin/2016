using UnityEngine;
using System.Collections;

public class BtnNewGame : MonoBehaviour {

    public AudioClip intro;
	tk2dUIItem ui;
	
	// Use this for initialization
	void Start () {
		ui = GetComponent<tk2dUIItem> ();
		ui.OnClick += NewGame;
	}

	void NewGame(){
        audio.PlayOneShot(intro);
		Application.LoadLevel ("OK SAVE THE SCENE");
	}
}
