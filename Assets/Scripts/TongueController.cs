﻿using UnityEngine;
using System.Collections;

public class TongueController : MonoBehaviour {

	public float finalScale = 5.0f;
	public float duration = 1.0f;

	public bool isAttacking = false;

	// Use this for initialization
	void Start () {
	
	}

	public void StartAttack(){
		if(!isAttacking){
			isAttacking = true;
			StartCoroutine("Attack");
		}
	}

	 IEnumerator Attack(){
		float t = 0;
		while(t <= duration){
			Vector3 newScale = transform.localScale;
			newScale.z = Mathf.Lerp(1.0f,finalScale,t/duration);
			transform.localScale = newScale;

			t += Time.deltaTime;
			yield return null;
		}

		t = duration;

		while(t >= 0.0f){
			Vector3 newScale = transform.localScale;
			newScale.z = Mathf.Lerp(1.0f,finalScale,t/duration);
			transform.localScale = newScale;

			t -= Time.deltaTime;
			yield return null;
		}

		t = 0.0f;

		isAttacking = false;
	}
}
