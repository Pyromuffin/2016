using UnityEngine;
using System.Collections;

public class PlayerHealth : MonoBehaviour {

	public int maxHealth = 10;
	public int currentHealth = 10;
    public AnimationCurve effectCurve;
    public float effectTime = 1f;
    public float blurStrength, vignetteStrength;
    public AudioClip[] ouchs;
    public bool dead = false;
	HealthBar healthBar;
	GameObject deadStateGO;
    Vignetting[] vignettes;
    public Animator animator;

	// Use this for initialization
	void Start () {
		currentHealth = maxHealth;
		healthBar = GameObject.FindObjectOfType<HealthBar> ();
		deadStateGO = GameObject.Find ("deadState");
        FindObjectOfType<GhostBar>().dsGO = deadStateGO;
		deadStateGO.SetActive (false);
       
        vignettes = FindObjectsOfType<Vignetting>();
	}
	
	// Update is called once per frame
	void Update () {
		
	
	}

    IEnumerator hitEffect()
    {
        float timer = 0;
        audio.PlayOneShot(ouchs[Random.Range(0, ouchs.Length)]);
        while (timer < 1)
        {
            foreach (var v in vignettes)
            {
                v.intensity = effectCurve.Evaluate(timer) * vignetteStrength;
                v.blur = effectCurve.Evaluate(timer) * blurStrength;
            }
            timer += Time.deltaTime / effectTime;
            yield return null;
        }
    }

	public void TongueAttack(){
        if (!dead)
        {
            
            currentHealth--;
            healthBar.DecrementHealth(1);
            StartCoroutine(hitEffect());
            CheckDeath();
        }
	}

	public void GhostAttack(){
        if (!dead) 
        { 
            
		    currentHealth -= 2;
        
            StartCoroutine(hitEffect());
		    healthBar.DecrementHealth (2);
		    CheckDeath ();
        }
	}

	//Are we dead? If so: do dead things!
	public void CheckDeath(){
		if(currentHealth <= 0){
			//show dead state
			Debug.Log ("DEAD");
            dead = true;
            foreach (var v in vignettes)
            {
                StopAllCoroutines();
                v.intensity = 20;
                v.blur = 50;
                v.blurSpread = 20;
                v.blurDistance = 30;
            }

            animator.SetTrigger("die");

            var cops = FindObjectsOfType<CopAI>();
            var ghosts = FindObjectsOfType<GhostAI>();

            foreach (var c in cops)
                c.enabled = false;
            foreach (var g in ghosts)
                g.enabled = false;

            FindObjectOfType<OVRPlayerController>().enabled = false;
            deadStateGO.SetActive(true);
            deadState.ShowDeath();
			
			//Lose Game stuff
		}
	}
}
