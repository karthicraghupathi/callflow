// Callflow javascript file
// by Arnaud Morin <arnaud.morin@gmail.com>
// 
// 




// getFrame function return overlib stick with Frame content
function getFrame(frame){
    var xhr_object = null;
    var str = "Error"

		if(window.XMLHttpRequest) // Firefox
			 xhr_object = new XMLHttpRequest();
		else if(window.ActiveXObject) // Internet Explorer
			 xhr_object = new ActiveXObject("Microsoft.XMLHTTP");
		else { // XMLHttpRequest non supporté par le navigateur
			 alert("XMLHTTPRequest not supported by your navigator...");
			 return;
		}

		xhr_object.open("GET", frame, false);
		xhr_object.send(null);

		if(xhr_object.readyState == 4) str = "" + xhr_object.responseText;
    return overlib(str, STICKY, MOUSEOFF);
   }
