

var mess1 = "\
At the end of this experiment, you will receive a verification code that you can use to validate your Mechanical Turk task. You can quit your trial at any point."


var mess2 = "\
In this experiment, you will learn three underwater songs! \
<br /> <br />\
Here are three fish that live in the ocean. Each fish sings a special song: \
<br /> <br />\
<img id=\"robot\" src=\"images/backgrounds/RobotsWithFlags.png\" style=\"max-width:70%; max-height:70%; height:auto; width:auto;\">\
<br />\
"

var mess3 = "\
On the right you can see the ‘bleeper’: This is the control panel you’ll use to let the fish sing a song. Press-and-hold on the bleeper, and drag to produce tunes. When you release, the fish stops singing. Try it!\
<br /> <br />\
Try to produce songs using vertical (up or down) movements. Horizontal movements (sideways) don't affect the songs produced.\
<br /> <br />\
Pay specific attention to how the pitch changes as you move up and down. Take your time to explore the bleeper.\
"

var mess3_left = "\
On the left you can see the ‘bleeper’: This is the control panel you’ll use to let the fish sing a song. Press-and-hold on the bleeper, and drag to produce tunes. When you release, the fish stops singing. Try it!\
<br /> <br />\
Try to produce songs using vertical (up or down) movements. Horizontal movements (sideways) don't affect the songs produced.\
<br /> <br />\
Pay specific attention to how the pitch changes as you move up and down. Take your time to explore the bleeper.\
"

// this can be changed in handleData.js (checkExperimentOptions());
var instructionMessages = []; // these are set in checkExperimentOptions
var slideWhistleAppear =  [];


var initialInstructionRoundCount = 0;


var pretestMessage = '\
We need to make sure your browser can handle the sound in this experiment.\
<br /><br />\
When you click the button below, you should hear two sounds, which should sound the same.\
<br /><br />\
Make sure your audio is on and loud enough!\
<br /><br />\
<input id="PlayPretestButton" type="button" onclick="playPretest()" ontouchend="playPretest()" value="Test your sound">\
'

var pretestMessage2 = '\
<strong>Did the two sounds sound similar?</strong>\
<br /><br />\
If they did, click the first button.\
<br /><br />\
If the second sound very was jittery, or you only heard one sound, click the second option. \
<br /><br />\
<input type="button" onclick="pretestResult(true)" value="Both sounds played and were similar">\
<br /><br />\
<input type="button" onclick="pretestResult(false)" value="The second sound did not play or was jittery">\
<br /><br />\
<input id="replayPretestButton" type="button" onclick="playPretest()" value="Oops, something went wrong - listen again!">\
';


var participantReportsSoundIsFinePostTest = true;

var postTest_MESSAGE = '\
Nearly done!\
<br /><br />\
Did you have problems with the sound during the experiment?\
<br /><br />\
<input type="button" onclick="postTestResult(true)" value="The sound seemed fine" style="font-size:20px">\
<br /><br /><br /><br />\
<input type="button" onclick="postTestResult(false)" value="The sound was jittery or slow" style="font-size:20px">';

function checkExperimentOptions(){

	instructionMessages = [];
	slideWhistleAppear =  [];

	var experParams = getQueryParams(document.location.search);

	var leftHandedExper = false;
	if("SONA" in experParams){
		SONAExperiment = true;

	}
	if("left" in experParams){
		leftHandedExper =true;
		console.log("LEFT");
		document.getElementById("mystyle").href = "css/style_tablet_leftHanded.css";
		}

	if("noquestions" in experParams){
		askParticipantsForAgeGenderLang =false;
		}


	if(!SONAExperiment){
		instructionMessages.push(mess1);
		slideWhistleAppear.push(false);
	}

	if(askParticipantsForAgeGenderLang){
		if(SONAExperiment){
			instructionMessages.push(pDetailsForm_SONA);
			slideWhistleAppear.push(false);
		} else{
			instructionMessages.push(pDetailsForm);
			slideWhistleAppear.push(false);
		}
	}

	instructionMessages.push(mess2);
	slideWhistleAppear.push(false);

	if(leftHandedExper){
		instructionMessages.push(mess3_left);
		slideWhistleAppear.push(true);
	} else{
		instructionMessages.push(mess3);
		slideWhistleAppear.push(true);
	}


}


function inititialInstructionRound(){

  if(initialInstructionRoundCount >= instructionMessages.length){
    // do this now, so that we have data on age, gender etc.
    writeClientDetails();
    roundCounter += 1;
    setTimeout("nextRound();",50);
  } else{
    setBigInstruction(instructionMessages[initialInstructionRoundCount]);
    if(slideWhistleAppear[initialInstructionRoundCount]){
      showMe("SlideWhistle");
      startSlideWhistle();
    } else{
      hideMe("SlideWhistle");
    }
    setTimeout("showMe('NextButton')",1000);
    initialInstructionRoundCount += 1;
  }

}



function setBigInstruction(message){
	document.getElementById("BigInstructions").innerHTML = message;
	if(message==""){
		hideMe("BigInstructions");
	} else{
		showMe("BigInstructions");
	}
}

function showPretestMessage(){
  setBigInstruction(pretestMessage);
}

function playPretest(){
  if(document.getElementById("PlayPretestButton")){
    hideMe("PlayPretestButton");
  }
  setBigInstruction(listen_MESSAGE);

  document.getElementById("exampleAudio").currentTime=0;
  document.getElementById("exampleAudio").play()
}

document.getElementById("exampleAudio").onended = function() {
    setTimeout("playPretest2()",1000);
};

function playPretest2(){
  var testHz = [0,25,50,75,100,125,150,175,200,225,250,275,300,325,350,375,400,425,450,475,500,525,550,575,600,625,650,675,700,725,750,775,800,825,850,875,900,925,950,975,1000];
  playSignalWithNode(testHz);
  // triggers exper_EndPlayback(), which sends to playPretest3()
}

function playPretest3(){
  setBigInstruction(pretestMessage2);
}

function pretestResult(audioWorked){
  if(audioWorked){
    nextRound();
  } else{
    cancelExperiment();
    tellClientAudioNotWorking();
  }
}


function postTestQuestions(){
  clearScreen();
  setBigInstruction(postTest_MESSAGE);
}


function postTestResult(audioWorked){
  if(!audioWorked){
    participantReportsSoundIsFinePostTest = false;
  }
  nextRound();
}
