using UnityEngine;
using System.Collections;

public class HueShift : MonoBehaviour {

	// Use this for initialization
    Material mat;
    public Shader hueShift;
    private float lerpAccumulator = 0;
    private static float hue, oldHue;
    public bool king = false;

    void Start()
    {
        mat = new Material(hueShift);
        hue = Random.value;
        oldHue = Random.value;
    }
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        mat.SetFloat("_Shift",  Mathf.Lerp(oldHue, hue, lerpAccumulator));
       
        Graphics.Blit(src, dest, mat);
        if (lerpAccumulator > 1)
        {
            if (king)
            {
                oldHue = hue;
                hue = Random.value;
            }
            lerpAccumulator = 0;
        }
        lerpAccumulator += Time.deltaTime;
    }
	
	// Update is called once per frame
	
}
