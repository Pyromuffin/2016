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
		if(goalPoint != null){
			navigation.SetDestination(goalPoint.position);
		}
	}
}
