using UnityEngine;
using System.Collections;

public class WallOffMeshLinkGizmos : MonoBehaviour {
    ParticleSystem particles;
    void Start()
    {
        particles = GetComponent<ParticleSystem>();
    }

    void OnTriggerEnter(Collider col)
    {
		if(col.gameObject.layer == LayerMask.NameToLayer("Ghost")){
	        var agent = col.GetComponent<NavMeshAgent>();
	        if (agent)
	        {
	            agent.speed = .5f;
	            particles.enableEmission = true;
	        }
		}

    }

    void OnTriggerExit(Collider col)
    {
        var agent = col.GetComponent<NavMeshAgent>();
        if (agent) { 
            agent.speed = 3f;
            particles.enableEmission = false;
        }
    }


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
