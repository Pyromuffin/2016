using UnityEngine;
using System.Collections;

public class deadState : MonoBehaviour {

	//Text!
	tk2dTextMesh text;
	tk2dUIItem btnRestart;
	tk2dUIItem btnQuit;

	string[] ominousMessages={"Was it worth it?",
	                          "There is no justice.",
	                          "I tried.",
							  "My heart is full of rage.",
							  "Ominous message."};

	// Use this for initialization
	void Start () {
		text = transform.Find ("txtOminous").GetComponent<tk2dTextMesh> ();
		btnRestart = transform.Find ("btnRestart").GetComponent<tk2dUIItem> ();
		btnQuit = transform.Find ("btnQuit").GetComponent<tk2dUIItem> ();
		SetText ();

		btnQuit.OnClick += QuitGame;
		btnRestart.OnClick += RestartGame;
	}
	
	// Update is called once per frame
	void Update () {
	
	}

	//Sets some OMINOUS TEXT
	public void SetText(){
		text.text = ominousMessages [Random.Range (0, ominousMessages.Length)];
	}

	//Quit game
	void QuitGame(){
		Application.Quit ();
	}

	//Restart game
	void RestartGame(){
		GameObject.Find ("healthBar").GetComponent<HealthBar> ().SetFullHealth ();
		GameObject.Find ("ghostBar").GetComponent<GhostBar> ().Reset ();
		SetText ();
		gameObject.SetActive (false);
	}
}
