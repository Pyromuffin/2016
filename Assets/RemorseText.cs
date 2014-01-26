using UnityEngine;
using System.Collections;

public class RemorseText : MonoBehaviour {

    string[] remorse = { "Was that worth it?", "Can blood buy freedom?", "I feel remorse", "I'm sorry, Brother", "Who decides what is right?", "We were once brothers", "I will not find peace here", "At what cost?" };
    TextMesh text;
    public float fadeInTime, fadeOutTime, stayTime;
	// Use this for initialization
	void Start () {
        text = GetComponent<TextMesh>();
	}
	
    IEnumerator showRemorse()
    {
        float timer = 0;
        text.text = remorse[Random.Range(0,remorse.Length)];
        while(timer < fadeInTime)
        {
            text.color =  new Vector4(1,1,1, Mathf.Lerp(0, 1, timer / fadeInTime) );
            timer += Time.deltaTime;
            yield return null;
            
        }
        
        timer = 0;
        while(timer < stayTime)
        {
            timer += Time.deltaTime;
            yield return null;
        }
        timer = 0;
        while( timer < fadeOutTime)
        {
            text.color =  new Vector4(1,1,1, Mathf.Lerp(1, 0, timer / fadeInTime) );
            timer += Time.deltaTime;
            yield return null;
        }

    }

	// Update is called once per frame
    public void feelRemorse()
    {
        StartCoroutine(showRemorse());
    }
}
