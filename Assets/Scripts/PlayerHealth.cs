using UnityEngine;
using System.Collections;

public class PlayerHealth : MonoBehaviour {

	public int maxHealth = 10;
	private int currentHealth = 10;

	// Use this for initialization
	void Start () {
		currentHealth = maxHealth;
	}
	
	// Update is called once per frame
	void Update () {
	
	}

	void OnGUI(){
		GUILayout.Label("Health: " + currentHealth.ToString());
	}

	public void TongueAttack(){
		Debug.Log ("TongueAttack in player");
		currentHealth--;

		if(currentHealth <= 0){
			//Lose Game stuff
		}
	}
}
