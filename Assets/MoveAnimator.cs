using UnityEngine;
using System.Collections;

public class MoveAnimator : MonoBehaviour {
    public Animator animator;
    public CharacterController cc;
	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
        animator.SetFloat("speed",cc.velocity.magnitude);
	}
}
