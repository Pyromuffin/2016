using UnityEngine;
using System.Collections;

public class PlayerHealth : MonoBehaviour {

	public int maxHealth = 10;
	public int currentHealth = 10;
    public AnimationCurve effectCurve;
    public float effectTime = 1f;
    public float blurStrength, vignetteStrength;
    public AudioClip[] ouchs;

	HealthBar healthBar;
	GameObject deadState;
    Vignetting[] vignettes;

	// Use this for initialization
	void Start () {
		currentHealth = maxHealth;
		healthBar = GameObject.FindObjectOfType<HealthBar> ();
		deadState = GameObject.Find ("deadState");
		deadState.SetActive (false);
       
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
		Debug.Log ("TongueAttack in player");
		currentHealth--;
		healthBar.DecrementHealth (1);
        StartCoroutine(hitEffect());
		CheckDeath ();
	}

	public void GhostAttack(){
		Debug.Log ("GhostAttack in player");
		currentHealth -= 2;
		healthBar.DecrementHealth (2);
		CheckDeath ();
	}

	//Are we dead? If so: do dead things!
	public void CheckDeath(){
		if(currentHealth <= 0){
			//show dead state
			Debug.Log ("DEAD");
			deadState.SetActive(true);
			
			//Lose Game stuff
		}
	}
}
