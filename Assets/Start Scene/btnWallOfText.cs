using UnityEngine;
using System.Collections;

public class btnWallOfText : MonoBehaviour {

	tk2dTextMesh text;
	tk2dUIItem ui;

	// Use this for initialization
	void Start () {
		ui = GetComponent<tk2dUIItem> ();
		ui.OnClick += ShowWall;
		text = GameObject.Find ("txtWall").GetComponent<tk2dTextMesh> ();
		text.gameObject.SetActive (false);
	}

	void ShowWall()
	{
		text.gameObject.SetActive (!text.gameObject.activeSelf);
	}
}
