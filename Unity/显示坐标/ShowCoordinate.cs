using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;

public class ShowCoordinate : MonoBehaviour {
	
	void OnGUI(){
		float x = Input.mousePosition.x;
		float y = Input.mousePosition.y;
		GUI.TextArea(new Rect(20,30,150,50), "x : " + x + " y : " + y); 
	}
}

