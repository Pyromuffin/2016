using UnityEngine;
using System.Collections;

public class CopFootstepManager : MonoBehaviour {

	public AudioClip[] footSteps;
	private AudioSource audioSource;
	private AudioLowPassFilter lowPassFilter;

	public float cutoffMultiplier = 500.0f;
	public AnimationCurve cutoffCurve;
	GameObject player;

	private int stepIndex = 0;
	public float stepDelay = 1.5f;
	private float timeSinceLastStep = 0.0f;

	// Use this for initialization
	void Awake () {
		audioSource   = GetComponent<AudioSource>();
		lowPassFilter = GetComponent<AudioLowPassFilter>();
		player = GameObject.FindGameObjectWithTag("Player");
	}
	
	// Update is called once per frame
	void Update () {
		float distanceToPlayer = (transform.position - player.transform.position).magnitude;
		lowPassFilter.cutoffFrequency = cutoffCurve.Evaluate(distanceToPlayer) * cutoffMultiplier;

		timeSinceLastStep += Time.deltaTime;

		if(timeSinceLastStep >= stepDelay){
			//Get a random footstep, but ensure that it's different from the one just played
			stepIndex = (stepIndex + Random.Range(0,footSteps.Length-1)) % footSteps.Length;
			audioSource.clip = footSteps[stepIndex];
			audioSource.Play();
			timeSinceLastStep = 0.0f;
		}
	}
}
