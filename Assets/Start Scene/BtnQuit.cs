using UnityEngine;
using System.Collections;

public class BtnQuit : MonoBehaviour {
	tk2dUIItem ui;

	// Use this for initialization
	void Start () {
		ui = GetComponent<tk2dUIItem> ();
		ui.OnClick += QuitGame;
	}

	void QuitGame(){
		Application.Quit ();
	}
}
