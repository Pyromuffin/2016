using UnityEngine;
using System.Collections;
public class copWalking : MonoBehaviour {
    public float stepDistance = .2f;
    Vector3 previousStepPosition;
    public AudioClip[] stepSounds;
    Vector3 nextDestination;
    float lerpAccumulator = 0;
	// Use this for initialization
	void Start () {
        previousStepPosition = transform.position;
        nextDestination = transform.position + Random.insideUnitSphere;
        nextDestination.y = 0;
    }
	
	// Update is called once per frame
	void Update () {

        if ((previousStepPosition - transform.position).magnitude >= stepDistance)
        {
            audio.clip = stepSounds[Random.Range(0, stepSounds.Length)];
            audio.Play();
            previousStepPosition = transform.position;

        }

        if (lerpAccumulator > 1)
        {
            nextDestination = transform.position + Random.insideUnitSphere;
            nextDestination.y = 0;
            lerpAccumulator = 0;
        }
        transform.position = Vector3.Lerp(transform.position, nextDestination, lerpAccumulator);


	}
}
