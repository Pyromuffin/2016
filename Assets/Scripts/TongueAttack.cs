using UnityEngine;
using System.Collections;

public class TongueAttack : MonoBehaviour {

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}

	void OnTriggerEnter(Collider col){
		Debug.Log ("OnTriggerEnter");
		if(col.tag == "Player"){
			Debug.Log("Message to player");
			col.gameObject.GetComponent<PlayerHealth>().TongueAttack();
		}
	}
}
