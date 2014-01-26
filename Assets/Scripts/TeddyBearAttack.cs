using UnityEngine;
using System.Collections;

public class TeddyBearAttack : MonoBehaviour {

	public string buttonName = "Fire1";
	public float teddyRange = 5.0f;
	public string teddyName = "TeddyBear";
	public GameObject teddy;

	public float chargeTime = 1.0f;

	private float timeButtonHeldDown = 0.0f;

	//private bool isAttacking  = false;

	// Use this for initialization
	void Start () {
		teddy = GameObject.Find(teddyName);
	}
	
	// Update is called once per frame
	void Update () {
		teddy.GetComponent<TeddyCharging>().chargeLevel = Mathf.Clamp01(timeButtonHeldDown/chargeTime);

		if(timeButtonHeldDown >= chargeTime && Input.GetButtonUp(buttonName)){
			AttackWithBear();
		}

		if(Input.GetButton(buttonName)){
			timeButtonHeldDown += Time.deltaTime;
		}
		else{
			timeButtonHeldDown = 0.0f;
		}
		
	}

	void AttackWithBear(){
		foreach(RaycastHit hit in Physics.SphereCastAll(transform.position, 0.25f, GetComponentInChildren<Camera>().transform.forward, teddyRange)){
			if(hit.transform.gameObject.layer == LayerMask.NameToLayer("Ghost")){
				hit.transform.gameObject.SendMessage("TeddyAttack", SendMessageOptions.DontRequireReceiver);
			}
		}
	}
}
