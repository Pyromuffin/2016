using UnityEngine;
using System.Collections;

public class ButtonManager : MonoBehaviour {

	public int levelId;

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}

	void QuitGame(){
		Application.Quit();
	}

	void StartGame(){
		Application.LoadLevel(levelId);
	}
}
