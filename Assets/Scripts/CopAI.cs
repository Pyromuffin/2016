using UnityEngine;
using System.Collections;

public class CopAI : MonoBehaviour {
	public enum AIState{
		Patrol,
		NoticePlayer,
		ChasingPlayer,
		ReturningToPatrol
		//AttackingPlayer
	};
	
	private PathToGoal pathManager;
	private StepSounds stepSounds;
	private GameObject player;
	
	public GameObject[] patrolPoints;
	private int currentPatrolPoint;
	
	private AIState currentState;

	private Vector3 lastPatrollingPosition;

	private float timeSinceLastSawPlayer = 0.0f;
	private float timeSeeingPlayer = 0.0f;
	public float maxTimeInNoticeRange = 3.0f;

	public float turningSpeed = 80.0f;

	public LayerMask seePlayerLayer;
	public float seePlayerDistance = 40.0f;
	public float seePlayerFOVAngle = 80.0f;
	private float seePlayerFOVCosine = 0.0f; //Cosine of the FOV angle the ghost can see the player in

	public float distanceToStopChasingPlayer = 30.0f;
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

		Debug.Log(currentState);
		bool canSeePlayer = CanSeePlayer();

		float playerDist = (transform.position - player.transform.position).magnitude;

		switch(currentState){
		case AIState.Patrol:
			pathManager.goalPoint = patrolPoints[currentPatrolPoint].transform;

			if(canSeePlayer){
				timeSinceLastSawPlayer = 0.0f;
				timeSeeingPlayer += Time.deltaTime;

				if(playerDist < noticePlayerDistance){
					currentState = AIState.NoticePlayer;
				}
				if(playerDist < chasePlayerDistance){
					currentState = AIState.ChasingPlayer;
				}
			}
			else{
				timeSinceLastSawPlayer += Time.deltaTime;
				timeSeeingPlayer = 0.0f;
			}
			break;


		case AIState.NoticePlayer:
			pathManager.goalPoint = null;
			RotateTowardPlayer(turningSpeed);

			if(canSeePlayer){
				timeSinceLastSawPlayer = 0.0f;
				timeSeeingPlayer += Time.deltaTime;

				if(playerDist < noticePlayerDistance){
					if(timeSeeingPlayer >= maxTimeInNoticeRange){
						currentState = AIState.ChasingPlayer;
					}
				}
				if(playerDist < chasePlayerDistance){
					currentState = AIState.ChasingPlayer;
				}
			}
			else{
				lastPatrollingPosition = transform.position;
				currentState = AIState.ReturningToPatrol;
				timeSinceLastSawPlayer += Time.deltaTime;
				timeSeeingPlayer = 0.0f;
			}
			break;

		case AIState.ChasingPlayer:
			pathManager.goalPoint = player.transform;

			if((transform.position - lastPatrollingPosition).magnitude >= distanceToStopChasingPlayer){
				currentState = AIState.ReturningToPatrol;
			}
			break;
		case AIState.ReturningToPatrol:
			pathManager.goalPoint = patrolPoints[currentPatrolPoint].transform;

			//If the cop is halfway back to their patrol
			if((transform.position - patrolPoints[currentPatrolPoint].transform.position).magnitude <= distanceToStopChasingPlayer/2.0f){
				currentState = AIState.Patrol;
			}
			break;
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
			//If it hits player
			if(hit.transform.tag == "Player"){ 
				//Find the vector towards the player, while ignoring the y-axis
				Vector3 playerDirection = (player.transform.position - transform.position);
				Vector3 playerDirectionWithoutY = playerDirection;
				playerDirectionWithoutY.y = 0.0f;
				
				//If the player is within the cop's FOV
				if(Vector3.Dot(playerDirectionWithoutY.normalized, transform.forward) > seePlayerFOVCosine){
					return true;
				}
			}
		}
		
		return false;
	}

	void RotateTowardPlayer(float maxDegreesDelta){
		transform.rotation = Quaternion.RotateTowards(transform.rotation, 
		                                              Quaternion.LookRotation(player.transform.position - transform.position), 
		                                              maxDegreesDelta);
	}
}
