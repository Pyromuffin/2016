using UnityEngine;
using System.Collections;

public class GhostAI : MonoBehaviour {

	private PathToGoal pathManager;
    private StepSounds stepSounds;
    private GameObject player;
    public GameObject[] arms;

	public GameObject[] patrolPoints;
	private GameObject currentPatrolPoint;

	private bool seesPlayer = false;
	private bool isChasingPlayer = false;

    enum ghostState { patrolling, notice, pursuing, waiting, attacking };

    ghostState state = ghostState.patrolling;

    float detectRadius = 8;
    float noticeToPursueTime = 2;
    float chaseRadius = 30;
    float waitTime = 1;
    float attackRadius = 2;
    Vector3 previousPatrolPosition;

    float noticeTimer = 0;
    float waitTimer = 0;

	public LayerMask seePlayerLayer;
	public float seePlayerDistance = 50.0f;
	public float seePlayerFOVAngle = 80.0f; 
	private float seePlayerFOVCosine = 0.0f; //Cosine of the FOV angle the ghost can see the player in
	public float chasePlayerTime = 8.0f;
	private float timeSinceLastSawPlayer = 0.0f;
    private int currentPatrolIndex = 0;

	// Use this for initialization
	void Start () {
        previousPatrolPosition = transform.position;
		pathManager = GetComponent<PathToGoal>();
		player = GameObject.FindGameObjectWithTag("Player");
		currentPatrolPoint = RandomPatrolPoint();
        stepSounds = GetComponent<StepSounds>();

		seePlayerFOVCosine = Mathf.Cos(seePlayerFOVAngle);
	}

    int nextPatrolIndex()
    {
        currentPatrolIndex++;
        currentPatrolIndex %= patrolPoints.Length;
        return currentPatrolIndex;

    }

    bool checkPlayerWithLOS()
    {
        return Physics.CheckSphere(transform.position, detectRadius, 1 << LayerMask.NameToLayer("Player")) && !Physics.Linecast(transform.position, player.transform.position, 1 << LayerMask.NameToLayer("Walls"));
    }

   

	// Update is called once per frame
	void Update () {


        switch (state)
        {
            case ghostState.patrolling:
                pathManager.goalPoint = patrolPoints[currentPatrolIndex].transform;
                
                if ( checkPlayerWithLOS() )
                {
                    state = ghostState.notice;
                    noticeTimer = 0;
                }

                break;
            case ghostState.notice:
                if (checkPlayerWithLOS())
                {
                    transform.forward = Vector3.Lerp(transform.forward, player.transform.position - transform.position, Time.deltaTime );
                    audio.pitch = 1 + noticeTimer / noticeToPursueTime;

                    noticeTimer += Time.deltaTime;
                    pathManager.goalPoint = transform;

                    if (noticeTimer > noticeToPursueTime)
                    {
                        previousPatrolPosition = transform.position;
                        state = ghostState.pursuing;
                    }
                }
                else
                {
                    state = ghostState.waiting;
                    audio.pitch = 1;
                    waitTimer = 0;
                }
            

                break;
            case ghostState.pursuing:
                pathManager.goalPoint = player.transform;
                if ((previousPatrolPosition - transform.position).magnitude > chaseRadius)
                {
                    //player outran ghost
                    state = ghostState.waiting;
                    audio.pitch = 1;
                    waitTimer = 0;
                }



                break;
            case ghostState.waiting:

                /*
                if (Physics.CheckSphere(transform.position, detectRadius, 1 << LayerMask.NameToLayer("Player")))
                {
                    state = ghostState.notice;
                    noticeTimer = 0;
                }
                */

                pathManager.goalPoint = transform;


                waitTimer += Time.deltaTime;
                if (waitTimer > waitTime)
                {
                    state = ghostState.patrolling;
                }


                break;
            case ghostState.attacking:
                StartCoroutine(attack());
                
                waitTimer = 0;
                state = ghostState.waiting;

                
                break;
            default:
                break;
        }



        if (checkPlayerWithLOS() && (transform.position - player.transform.position).magnitude < attackRadius)
        {
            if(state != ghostState.waiting)
                state = ghostState.attacking;
        }


       
	}

    IEnumerator attack()
    {
        float rotation = 0;

        while (rotation < 360)
        {
            foreach (var arm in arms)
            {
                rotation += Time.deltaTime * 360;
            }
            yield return null;
        }
    }

	void OnTriggerEnter(Collider col){
		if(col.tag == "Patrol" && col.gameObject == patrolPoints[currentPatrolIndex]){
            currentPatrolIndex++;
            currentPatrolIndex %= patrolPoints.Length;
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
