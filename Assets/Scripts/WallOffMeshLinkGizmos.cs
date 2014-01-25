using UnityEngine;
using System.Collections;

public class WallOffMeshLinkGizmos : MonoBehaviour {

	void OnDrawGizmos(){
		Gizmos.color = Color.white;
		Gizmos.DrawWireCube(transform.position,Vector3.one);

		Gizmos.color = Color.blue;
		Gizmos.DrawWireSphere(transform.FindChild("FromPoint").position,0.25f);
		Gizmos.DrawLine(transform.position, transform.FindChild("FromPoint").position);

		Gizmos.DrawWireSphere(transform.FindChild("ToPoint").position,0.25f);
		Gizmos.DrawLine(transform.position, transform.FindChild("ToPoint").position);
	}
}
