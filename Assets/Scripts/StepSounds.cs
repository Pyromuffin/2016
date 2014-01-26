using UnityEngine;
using System.Collections;
[RequireComponent(typeof(AudioSource))]
[RequireComponent(typeof(AudioLowPassFilter))]
[RequireComponent(typeof(AudioReverbFilter))]
public class StepSounds : MonoBehaviour {
    public float stepDistance = .2f;
    Vector3 previousStepPosition;
    public AudioClip[] stepSounds;
    GameObject player;
    AudioLowPassFilter lowPass;
    AudioReverbFilter reverb;
    public bool ghost = false;
    public bool kid = false;
	// Use this for initialization
	void Start () {
        previousStepPosition = transform.position;
        player = GameObject.FindGameObjectWithTag("Player");
        lowPass = GetComponent<AudioLowPassFilter>();
        reverb = GetComponent<AudioReverbFilter>();
    }
	
	// Update is called once per frame
	void Update () 
    {

        if ((previousStepPosition - transform.position).magnitude >= stepDistance)
        {
            if (!kid)
            {
                if (Physics.Linecast(player.transform.position, transform.position, 1 << LayerMask.NameToLayer("Walls")))
                {
                    //there is something between 
                    lowPass.enabled = true;
                    audio.volume = .15f;
                    reverb.enabled = true;
                }
                else
                {
                    lowPass.enabled = false;
                    reverb.enabled = false;
                    audio.volume = .75f;
                }
            }

            if(!ghost)
                audio.PlayOneShot(stepSounds[Random.Range(0, stepSounds.Length)], kid? .3f: 1);
            previousStepPosition = transform.position;

        }


	}
}
