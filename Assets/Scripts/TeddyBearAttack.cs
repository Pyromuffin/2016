using UnityEngine;
using System.Collections;

public class TeddyBearAttack : MonoBehaviour {

	public string buttonName = "Fire1";
	public float teddyRadius = 5.0f;

	private bool isAttacking  = false;

	// Use this for initialization
	void Start () {
	}
	
	// Update is called once per frame
	void Update () {
		if(Input.GetButtonDown(buttonName)){
			foreach(Collider col in Physics.OverlapSphere(transform.position, teddyRadius)){
				if(col.gameObject.layer == LayerMask.NameToLayer("Ghost")){
					col.gameObject.SendMessage("TeddyAttack",SendMessageOptions.DontRequireReceiver);
					Debug.Log("Teddy Attack");
				}
			}
		}
	
	}
}
