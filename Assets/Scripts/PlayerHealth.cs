using UnityEngine;
using System.Collections;

public class PlayerHealth : MonoBehaviour {

	public int maxHealth = 10;
	public int currentHealth = 10;

	HealthBar healthBar;
	GameObject deadStateObj;

	// Use this for initialization
	void Start () {
		currentHealth = maxHealth;
		healthBar = GameObject.FindObjectOfType<HealthBar> ();
		deadStateObj = GameObject.Find ("deadState");
		deadStateObj.SetActive (false);
	}

	public void TongueAttack(){
		Debug.Log ("TongueAttack in player");
		currentHealth--;
		healthBar.DecrementHealth (1);
		CheckDeath ();
	}

	public void GhostAttack(){
		Debug.Log ("GhostAttack in player");
		currentHealth -= 2;
		healthBar.DecrementHealth (2);
		CheckDeath ();
	}

	//Are we dead? If so: do dead things!
	public void CheckDeath(){
		if(currentHealth <= 0){
			//show dead state
			deadState.ShowDeath();
			deadStateObj.SetActive(true);
		}
	}
}
