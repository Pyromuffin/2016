using UnityEngine;
using System.Collections;

public enum AIState{
	Patrol,
	NoticePlayer,
	ChasingPlayer,
	ReturningToPatrol,
	AttackingPlayer
};

public class CopAI : MonoBehaviour {
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
	public float patrolReturnTimeout = 2.0f; //After going into return to patrol,
	public float attackRange = 2.0f;
	
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
					lastPatrollingPosition = transform.position;
					currentState = AIState.NoticePlayer;
				}
				if(playerDist < chasePlayerDistance){
					lastPatrollingPosition = transform.position;
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
			if(playerDist <= attackRange){
				currentState = AIState.AttackingPlayer;
			}
			break;

		case AIState.AttackingPlayer:
			//Don't path toward anything, and try to face the player
			pathManager.goalPoint = null;
			RotateTowardPlayer(turningSpeed);

			if(playerDist > attackRange){
				currentState = AIState.ChasingPlayer;
			}
			else{
				GameObject tongueParent = transform.FindChild("TongueParent").gameObject;
				tongueParent.GetComponent<TongueController>().StartAttack();
			}

			break;

		case AIState.ReturningToPatrol:
			pathManager.goalPoint = patrolPoints[currentPatrolPoint].transform;

			if(!IsInvoking("GoBackToPatrol")){
				//Set a timer for going back to just patrolling (so the cop doesn't flip between each state constantly)
				Invoke("GoBackToPatrol", patrolReturnTimeout);
			}
			break;
		}
		
	}

	void GoBackToPatrol(){
		currentState = AIState.Patrol;
	}
	
	void OnTriggerEnter(Collider col){
		if(col.tag == "Patrol" && col.gameObject == patrolPoints[currentPatrolPoint]){
			currentPatrolPoint = (currentPatrolPoint+1)%patrolPoints.Length;
		}
	}
	
	GameObject RandomPatrolPoint(){
		return patrolPoints[Random.Range(0,patrolPoints.Length)];
	}

	public AIState GetCurrentState(){
		return currentState;
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
