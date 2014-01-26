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
    public float cutoffIncrease = 100;
    public AudioClip wob;

	public float chargeTime = 1.0f;
    float wubTimer = 0;
    Transform cameraController;

	private float timeButtonHeldDown = 0.0f;

	//private bool isAttacking  = false;

	// Use this for initialization
	void Start () {
        cameraController = FindObjectOfType<OVRCameraController>().transform;
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
            wubFilter.cutoffFrequency += Time.deltaTime * cutoffIncrease;
            if (wubTimer > wubRate) { 
               Instantiate(wub,bearParticles.transform.position + cameraController.forward, Quaternion.identity);
               wubTimer = 0;
            }

		}
		else{
            wubDispenser.Stop();
            audio.PlayOneShot(wob, 1);
			timeButtonHeldDown = 0.0f;
            wubFilter.cutoffFrequency = 100;
		}
		
	}

	void AttackWithBear(){
		foreach(RaycastHit hit in Physics.SphereCastAll(transform.position, 0.25f, GetComponentInChildren<Camera>().transform.forward, teddyRange)){
			if(hit.transform.gameObject.layer == LayerMask.NameToLayer("Ghost")){
				hit.transform.gameObject.SendMessage("TeddyAttack", SendMessageOptions.DontRequireReceiver);
			}
		}
	}
}
