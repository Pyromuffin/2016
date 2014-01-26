using UnityEngine;
using System.Collections;

public class deadState : MonoBehaviour {

	//Text!
	static tk2dTextMesh text;
	static tk2dUIItem btnRestart;
	static tk2dUIItem btnQuit;
	static tk2dTextMesh txtVictory;

	string[] victoryMessages={"There are no winners in war.",
		"I am justice.",
		"Revenge.",
		"Might makes win.",
		"The only winning move is to win.",
		"The only winning move is to\nkill all of your brothers.",
		"I have found glory in battle."};

	string[] ominousMessages={"Was it worth it?",
	                          "There is no justice.",
	                          "I tried.",
							  "My heart is full of rage.",
							  "Ominous message.",
							  "Is this the world we wish to live in?"};

	// Use this for initialization
	void Awake () {
        
		text = transform.Find ("txtOminous").GetComponent<tk2dTextMesh> ();
		text.text = ominousMessages [Random.Range (0, ominousMessages.Length)];
		btnRestart = GameObject.Find("btnRestart").GetComponent<tk2dUIItem> ();
		btnQuit = GameObject.Find ("btnQuit").GetComponent<tk2dUIItem> ();
		txtVictory = GameObject.Find ("txtVictory").GetComponent<tk2dTextMesh> ();
		txtVictory.text = victoryMessages [Random.Range (0, victoryMessages.Length)];

		txtVictory.gameObject.SetActive (false);
		btnRestart.gameObject.SetActive (false);
		btnQuit.gameObject.SetActive (false);
		text.gameObject.SetActive (false);

		SetText ();

		btnQuit.OnClick += QuitGame;
		btnRestart.OnClick += RestartGame;
	}

	public static void ShowDeath(){
        Screen.lockCursor = false;
        Screen.showCursor = true;
		btnRestart.gameObject.SetActive (true);
		btnQuit.gameObject.SetActive (true);
		text.gameObject.SetActive (true);
	}

	public static void ShowVictory(){
        Screen.lockCursor = false;
        Screen.showCursor = true;
		btnRestart.gameObject.SetActive (true);
		btnQuit.gameObject.SetActive (true);
		txtVictory.gameObject.SetActive (true);
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
		Application.LoadLevel ("OK SAVE THE SCENE");
	}
}
