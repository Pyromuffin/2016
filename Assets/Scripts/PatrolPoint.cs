using UnityEngine;
using System.Collections;

public class PatrolPoint : MonoBehaviour {

	void OnDrawGizmos(){
		Gizmos.DrawWireCube(transform.position, Vector3.one);
	}
}
