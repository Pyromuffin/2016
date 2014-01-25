using UnityEngine;
using System.Collections;

public class GhostAI : MonoBehaviour {

	private PathToGoal pathManager;
	private GameObject player;

	public GameObject[] patrolPoints;
	private GameObject currentPatrolPoint;

	private bool seesPlayer = false;
	private bool isChasingPlayer = false;

	public LayerMask seePlayerLayer;
	public float seePlayerDistance = 50.0f;
	public float FOVangle = 50.0f; //NOTE: Does not live update
	public float seePlayerFOVCosine = 0.6f; //Cosine of the FOV angle the ghost can see the player in
	public float chasePlayerTime = 8.0f;
	private float timeSinceLastSawPlayer = 0.0f;

	// Use this for initialization
	void Start () {
		patrolPoints = GameObject.FindGameObjectsWithTag("Patrol");
		pathManager = GetComponent<PathToGoal>();
		player = GameObject.FindGameObjectWithTag("Player");
		currentPatrolPoint = RandomPatrolPoint();

		seePlayerFOVCosine = Mathf.Cos(FOVangle);
	}
	
	// Update is called once per frame
	void Update () {
		if(CanSeePlayer()){
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
			pathManager.goalPoint = currentPatrolPoint.transform;
		}	
	}

	void OnTriggerEnter(Collider col){
		if(col.tag == "Patrol" && col.gameObject == currentPatrolPoint){
			currentPatrolPoint = RandomPatrolPoint();
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

				//If the player is within the ghost's FOV
				if(Vector3.Dot(playerDirectionWithoutY.normalized, transform.forward) > seePlayerFOVCosine){
					return true;
				}
			}
		}

		return false;
	}
}
