
function setTextStimulus(text){
	showMe("TextStimulus");
	document.getElementById("TextStimulus").innerHTML = text
	}

function setInstruction(text){
	showMe("instructions");
	document.getElementById("instructions").innerHTML = text
	}

function hideMe(id){
	//console.log(["hideMe",id]);
	document.getElementById(id).style.display = 'none';
}

function showMe(id){
	//console.log(["showMe",id]);
	//console.log(id);
	document.getElementById(id).style.display = 'inline';
}

function setImage(id,src){
	//console.log(["setImage",id,src]);
	document.getElementById(id).src = src;
}

function setInstruction(message){
	document.getElementById("instructions").innerHTML = message;
	if(message==""){
		hideMe("instructions");
	} else{
		showMe("instructions");
	}
}

function getIP(){
	$.getJSON("http://jsonip.com/?callback=?", function (data) {
			 checkIP(data.ip);
	 });
 }
