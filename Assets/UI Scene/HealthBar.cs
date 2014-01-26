using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

public class HealthBar : MonoBehaviour {

	//Total health
	//There are 5 health hearts, but there are half hearts... so 10 HP

	//The hearts
	List<tk2dSprite> healthHearts;

	// Use this for initialization
	void Start () {
		tk2dSprite[] healthHeartsArr = gameObject.GetComponentsInChildren<tk2dSprite> ();
		healthHearts = new List<tk2dSprite> ();
		//Make sure we are set to full health
		foreach(tk2dSprite heart in healthHeartsArr){
			heart.SetSprite("heart_full");
			healthHearts.Add(heart);
		}

		//Sort list by x value
		healthHearts = healthHearts.OrderBy (u => u.transform.position.x).ToList ();
		healthHearts.Reverse ();
	}

	//Resets health
	public void SetFullHealth(){
		foreach(tk2dSprite heart in healthHearts){
			heart.SetSprite("heart_full");
		}
	}

	//Remove some HP
	public void DecrementHealth(int delta){

		//How much hp to remove
		int deltaHP = Mathf.Abs (delta);
		while (deltaHP > 0){
			//Look for the first non-empty heart

			bool foundNonEmpty = false;
			foreach(tk2dSprite heart in healthHearts){
				if(!foundNonEmpty){
					if (heart.spriteId != heart.GetSpriteIdByName("heart_empty")){
						//We found a valid heart. End this mad mad loop.
						foundNonEmpty = true;
						//full heart to half, half heart to empty
						if(heart.spriteId == heart.GetSpriteIdByName("heart_full")){
							heart.SetSprite("heart_half");
						}
						else if(heart.spriteId == heart.GetSpriteIdByName("heart_half")){
							heart.SetSprite("heart_empty");
						}
					}
				}
			}
			deltaHP--;
		}
	}
}
