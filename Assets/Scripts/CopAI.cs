using UnityEngine;
using System.Collections;

public class CopAI : MonoBehaviour {
	public enum AIState{
		Patrol,
		NoticePlayer,
		ChasingPlayer,
		AttackingPlayer
	};
	
	private PathToGoal pathManager;
	private StepSounds stepSounds;
	private GameObject player;
	
	public GameObject[] patrolPoints;
	private GameObject currentPatrolPoint;
	
	private AIState currentState;
	
	public float noticePlayerDistance = 20.0f;
	public float chasePlayerDistance = 10.0f;
	
	// Use this for initialization
	void Start () {
		pathManager = GetComponent<PathToGoal>();
		player = GameObject.FindGameObjectWithTag("Player");
		currentPatrolPoint = Random.Range(0,patrolPoints.Length);

		seePlayerFOVCosine = Mathf.Cos(seePlayerFOVAngle);
	}
	
	// Update is called once per frame
	void Update () {

		switch(currentState){
		case AIState.Patrol:

		case AIState.NoticePlayer:

		case AIState.ChasingPlayer:

		case AIState.AttackingPlayer:


		}


		/*if(CanSeePlayer()){
			seesPlayer = true;
			isChasingPlayer = true;
			timeSinceLastSawPlayer = 0.0f;
		}
		else{
			seesPlayer = false;
			timeSinceLastSawPlayer += Time.deltaTime;
		}
		
		if(isChasingPlayer){
			pathManager.goalPoint = player.transform;
			if(!seesPlayer && timeSinceLastSawPlayer >= chasePlayerTime){
				isChasingPlayer = false;
			}
		}
		else{
			pathManager.goalPoint = patrolPoints[currentPatrolPoint].transform;
		}*/
	}
	
	void OnTriggerEnter(Collider col){
		if(col.tag == "Patrol" && col.gameObject == patrolPoints[currentPatrolPoint]){
			currentPatrolPoint = (currentPatrolPoint+1)%patrolPoints.Length;
		}
	}
	
	GameObject RandomPatrolPoint(){
		return patrolPoints[Random.Range(0,patrolPoints.Length)];
	}
	
	bool CanSeePlayer(){
		RaycastHit hit;
		//If Raycast its something
		if(Physics.Raycast(transform.position, (player.transform.position - transform.position), out hit, seePlayerDistance, seePlayerLayer)){
			Debug.Log(hit.transform);
			//If it hits player
			if(hit.transform.tag == "Player"){ 
				//Find the vector towards the player, while ignoring the y-axis
				Vector3 playerDirection = (player.transform.position - transform.position);
				Vector3 playerDirectionWithoutY = playerDirection;
				playerDirectionWithoutY.y = 0.0f;
				
				//If the player is within the ghost's FOV
				if(Vector3.Dot(playerDirectionWithoutY.normalized, transform.forward) > seePlayerFOVCosine){
					return true;
				}
			}
		}
		
		return false;
	}
}
