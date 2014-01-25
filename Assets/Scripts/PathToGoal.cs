using UnityEngine;
using System.Collections;

public class PathToGoal : MonoBehaviour {

	public Transform goalPoint;
	private NavMeshAgent navigation;
	
	// Use this for initialization
	void Start () {
		//goalPoint = GameObject.FindGameObjectWithTag("Player").transform;
		navigation = GetComponent<NavMeshAgent>();
	}
	
	// Update is called once per frame
	void Update () {
		//Setting goalPoint to null will stop pathing until it is not null
		if(goalPoint != null){
			navigation.enabled = true;
			navigation.SetDestination(goalPoint.position);
		}
		else{
			navigation.enabled = false;
		}
	}
}
