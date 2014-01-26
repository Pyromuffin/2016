using UnityEngine;
using System.Collections;

public class BtnNewGame : MonoBehaviour {

	tk2dUIItem ui;
	
	// Use this for initialization
	void Start () {
		ui = GetComponent<tk2dUIItem> ();
		ui.OnClick += NewGame;
	}

	void NewGame(){
		Application.LoadLevel ("OK SAVE THE SCENE");
	}
}
