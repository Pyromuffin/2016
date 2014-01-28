using UnityEngine;
using System.Collections;

public class TeddyBearAttack : MonoBehaviour {

	public string buttonName = "Fire1";
	public float teddyRange = 5.0f;
	public string teddyName = "TeddyBear";
    TeddyCharging teddyCharging;
    public ParticleSystem bearParticles;
    public GameObject wub;
    public float wubRate;
    AudioLowPassFilter wubFilter;
    AudioSource wubDispenser;
    public float maxCutoff;
    public AudioClip wob, chime;
    public float laserTime = .5f;

    public LineRenderer line;
    public Animator animator;

    bool chimed = false;
	public float chargeTime = 1.0f;
    float wubTimer = 0;
    Transform cameraController;

	private float timeButtonHeldDown = 0.0f;

    IEnumerator LAZOR()
    {
        line.enabled = true;
        float laserTimer = 0;
        while (laserTimer < laserTime)
        {
            line.SetWidth(Mathf.Lerp(5, 0, laserTimer / laserTime), 1);
            laserTimer += Time.deltaTime;
            yield return null;

        }
        line.enabled = false;
    }


	//private bool isAttacking  = false;

	// Use this for initialization
	void Start () {
        cameraController = GameObject.Find("OVRPlayerController").transform;
        teddyCharging = FindObjectOfType<TeddyCharging>();
        var wubGO = GameObject.Find("Wub Dispenser");
        wubDispenser = wubGO.GetComponent<AudioSource>();
        wubFilter = wubGO.GetComponent<AudioLowPassFilter>();
	}
	
	// Update is called once per frame
	void Update () {
		teddyCharging.chargeLevel = Mathf.Clamp01(timeButtonHeldDown/chargeTime);

		if(timeButtonHeldDown >= chargeTime && Input.GetButtonUp(buttonName)){
			AttackWithBear();
		}
        if (Input.GetButtonDown(buttonName))
            wubDispenser.Play();

		if(Input.GetButton(buttonName)){
            
			timeButtonHeldDown += Time.deltaTime;
            wubTimer += Time.deltaTime;
            wubFilter.cutoffFrequency = Mathf.Lerp(100, maxCutoff, timeButtonHeldDown / chargeTime);
            if (wubTimer > wubRate) { 
               Instantiate(wub,bearParticles.transform.position + cameraController.forward, Quaternion.identity);
               wubTimer = 0;
            }


            if (timeButtonHeldDown > chargeTime && !chimed)
            {
                audio.PlayOneShot(chime);
                
                chimed = true;
            }

		}
		else{
            wubDispenser.Stop();
            
			timeButtonHeldDown = 0.0f;
            wubFilter.cutoffFrequency = 100;
		}
        if (Input.GetButtonUp(buttonName))
        {
            if (chimed)
            {
                animator.SetTrigger("attack");
                audio.PlayOneShot(wob, 1);
                StartCoroutine(LAZOR());
            }
            chimed = false;
        }
	}

	void AttackWithBear(){
		foreach(RaycastHit hit in Physics.SphereCastAll(transform.position, 0.5f, cameraController.forward, teddyRange)){
			if(hit.transform.gameObject.layer == LayerMask.NameToLayer("Ghost")){
				hit.transform.gameObject.SendMessage("TeddyAttack", SendMessageOptions.DontRequireReceiver);
			}
		}
	}
}
