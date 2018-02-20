

var experiment_state = "Instructions";

var finishedExperiment = false;

var roundOrder = [];
var roundStims = [];
var roundStim = 0;

var roundCounter = 0;

var trainingCount = 1;

var numberOfReproductionPhases = 1;


var windowHasLostBlur = false;

var sendSignalAfterFingerLift = true;
var instructionPhase = false;

var turkerCode = "SLD"+ (""+Math.random()).substring(2,7);

// if the participant has the page open for more than 4 hours, cancel the experiment
var runOutOfTime_timeout =setTimeout("runOutOfTime()",1000 * 60 * 60 * 4);


function listenerClick(optionChosen){
	// user has clicked one of the options in the guessing stage
	// optionChosen is an integer from 0 to 3
	hideMe("ListenAgain");
	if(experiment_state=="Learning"){
		playerGuessedInLearningPhase(optionChosen);
	}

}

function clickedNextButton(){

		stopRecord();
		nextRound();

//	if(experiment_state=='ReproduceTraining'){
	//}
}

function listenAgain(){

	if(experiment_state=="Learning"){
		// user wants to hear sound again before guessing
		hideMe("ListenAgain");
		hideMe("guessPanel");
		playSignal(signals[currentTarget]);
	} else{
		// this is in the initial reproduction phase
		if(!playingBack){
			hideMe("ListenAgain");
			hideMe("NextButton");
			stopRecord();
			//hideMe("SlideWhistle");
			if(showNodeInSliderDuringInitialTraining){
				playSignalWithNode(trainingSignals[roundStim]);
			} else{
				playSignal(trainingSignals[roundStim]);
			}
		}
	}
}

function setUpRoundOrder(){
	roundOrder = [];
	roundStims = [];

	roundOrder.push("SoundTest");
	roundStims.push(0);


	roundOrder.push("InitialInstruction");
	roundStims.push(0);

	roundOrder.push("Instruction")
	roundStims.push(reproductionTrainingRound_MESSAGE);

	// Add one training round per signal
	for(var i = 0; i < meanings.length; ++i){
		roundOrder.push("Training");
		roundStims.push(i);
		roundOrder.push("ReproduceTraining");
		roundStims.push(i);
	}

	roundOrder.push("Instruction")
	roundStims.push(preTrainingRound_MESSAGE);

	// Add Learning phase
	roundOrder.push("Learning");
	roundStims.push(0);

	roundOrder.push("Instruction")
	roundStims.push(finishedLearningPhase_MESSAGE);

	roundOrder.push("SliderRecap")
	roundStims.push(preReproductionPhase_MESSAGE);



	// Add reproduction round for each signal
	for(var x =0; x<numberOfReproductionPhases;++x){
		var reproOrder = [];
		for(var i = 0; i < meanings.length; ++i){
			reproOrder.push(i);
		}
		shuffle(reproOrder);
		for(var i = 0; i < meanings.length; ++i){
			roundOrder.push("Reproduction");
			roundStims.push(i);
		}
	}

	lastReproductionSignals = [];
	for(var i = 0; i < meanings.length; ++i){
		lastReproductionSignals.push([]);
	}

	roundOrder.push("PostTestQuestions");
	roundStims.push(0);

}

function nextRound(){
	clearScreen();
	// this is called after each round is completed, and it decides what happens next
	if(roundCounter >= roundOrder.length){
		endExperiment();
	} else{

		if(testRun){
			saveData(); // save data after every round in testing
		}

		//saveData();
		experiment_state = roundOrder[roundCounter];
		roundStim = roundStims[roundCounter];
		console.log("Next Round "+experiment_state+" "+roundStim);

		switch(experiment_state){
			case "SoundTest":
				showPretestMessage();
				roundCounter += 1;
				break;
			case "InitialInstruction":
				inititialInstructionRound();
				break;
			case "Instruction":
				instructionRound(roundStim);
				roundCounter += 1;
				break;
			case "Training":
				console.log("TRAINING");
				trainingRound(trainingSignals[roundStim]);
				roundCounter += 1;
				break;
			case "ReproduceTraining":
				reproductionTrainingRound(roundStim);
				roundCounter += 1;
				break;
			case "Learning":
				if(passedLearningPhase()){
					roundCounter += 1;
					setTimeout("nextRound();",1000);
				} else{
					learningPhase();
				}
				break;
			case "SliderRecap":
				roundCounter += 1;
				SliderRecap(roundStim);
				break;
			case "Reproduction":
				reproductionRound(roundStim);
				roundCounter += 1;
				break;
			case "PostTestQuestions":
				postTestQuestions(); // in instructions.js
				roundCounter += 1;
				break;
			default:
				break;
		}
	}

}

function clearScreen(){
	setImage("imageStimulusIMG","");
	hideMe("imageStimulus");
	hideMe("guessPanel");
	hideMe("instructions");
	hideMe("StartButton");
	hideMe("NextButton");
	hideMe("BigInstructions");
	setTextStimulus("");
	setInstruction("");
	hideMe("SlideWhistle");
	hideMe("ListenAgain");
	hideMe("SlideWhistleNode");
	hideMe("RetryButton");
}

function instructionRound(message){
	setInstruction(message);
	//setTimeout("nextRound()",2000);
	setTimeout('showMe("StartButton");',1000);
}

function SliderRecap(message){
	setInstruction(message);
	showMe("SlideWhistle");
	startSlideWhistle();
	showMe("NextButton");
}

function endExperiment(){
	console.log("End experiment");
	finishedExperiment = true;
	saveData();
	if(! (testRun & cancelExperimentImmedatelyInTestMode)){
		// unless we're in test mode, update the log
		updatelog();
	}
	if(! SONAExperiment){
		showCode();
	} else{
		setInstruction(endExperiment_MESSAGE_TABLET);
	}
	// stop experiment timing out
	clearTimeout(runOutOfTime_timeout);
}

function showCode(){
	var endMessage = endExperiment_MESSAGE;
	setInstruction(endMessage);
}


// For each trial, there are three phases:
//
// -          Training: Participants hear five sound they have to replicate (no meanings yet). This gives them a feeling how the flute works and how it maps to acoustics. (Open question: We have to be careful not to bias them to e.g., use the steep regions, or use e.g., quick movements or stationary ones (or maybe we do?). Anybody has any suggestions?)

function trainingRound(signal){
	experiment_state = "Training";
	if(showNodeInSliderDuringInitialTraining){
		showMe("SlideWhistle");
		playSignalWithNode(signal); // in this case, signal is an array of physical buffer positions
	} else{
		playSignal(signal);
	}
	setTextStimulus("Example "+trainingCount);
	trainingCount += 1;
}

function playSignal(signalX){
	//console.log("PLAY SIGNAL");
	//console.log(signalX);
	recordBuffer = bufferPadding.concat(signalX,bufferPadding);
 //	startSlideWhistle();
	setTimeout("startPlayback();",500)
}

function playSignalWithNode(physicalPositionX){
	// physicalPositionX is a list of values in physical position in linear space


	physicalBuffer = [];
	recordBuffer = [];

	// set flute to linear space
	theremin.setCurvature(0);
	for(var i=0;i<physicalPositionX.length; ++i){
	// 	// convert to physical position on our slider
	// 	theremin.setCurvature(curvature);
	// 	var pp = theremin.f_double_sigmoid(parseInt(physicalPositionX[i])/1000);
	//
	// 	physicalBuffer.push(pp * 1000);  // convert to format in results file
	// 	theremin.setCurvature(0);
	 	// convert to Hz
		var hzx = theremin.physicalPosToHz(parseInt(physicalPositionX[i])/1000);
	 	recordBuffer.push(hzx);
		// in soundSlider js
		var physx = hzToPhysicalFromConverstionTable(hzx);
		physicalBuffer.push(physx*1000);// conver to 1000 format

	 }
	 theremin.setCurvature(curvature);


	console.log(theremin.f_double_sigmoid(0));
	console.log(theremin.f_double_sigmoid(1));

	console.log("PlaybackWithNode");
	console.log(physicalPositionX);
	console.log(physicalBuffer);
	console.log(recordBuffer);

	recordBuffer =  bufferPadding.concat(recordBuffer,bufferPadding);
	physicalBuffer = bufferPadding.concat(physicalBuffer,bufferPadding);


//	startSlideWhistle();
	setTimeout("startPlaybackWithNode();",500);
}



function loadExperiment(){
	// called when user loads page

	// adjust meanings array to right number of meanings
	meanings = meanings.slice(0,numMeanings);
	addOptionDivs();

	checkIP();
	// initiate slider;
	initPage();
//	startSlideWhistle();
	showMe("StartButton");
	hideMe("SlideWhistle");
	hideMe("ListenAgain");
	hideMe("RetryButton");
	hideMe("NextButton");
	hideMe("guessPanel");
	showStartMessage();

}

function addOptionDivs(){
	//<img id="option1" onClick="listenerClick(0)">
	//<img id="option2" onClick="listenerClick(1)">
	//<img id="option3" onClick="listenerClick(2)">
	//<img id="option4" onClick="listenerClick(3)">

	var out = "";

	for(var i=0; i< numMeanings; ++i){
		out += '<img id="option' + (i+1) + '" onClick="listenerClick('+i+')">\n';
	}
	document.getElementById("guessPanel").innerHTML = out;

}

function preloadImages(){
	for(var i=0;i<signals.length;++i){
		setImage("option"+(i+1),meanings[i]);
	}
	hideMe("guessPanel");
}

function startExperiment(){

	if(signals.length==0){
		console.log(["start experiment",signals]);
		hideMe("StartButton");
		getExperimentData();
	} else{
		nextRound();
	}

}


function exper_EndPlayback(){
//	console.log("END PLAYBACK");
//	console.log(experiment_state);
	// soundSlider has finished playing back
	switch(experiment_state){
		case "SoundTest":
			playPretest3();
			break;
		case "Training":
			setTimeout("nextRound()",500);
			break;
		case "Learning":
			if(learningRoundState=="Testing"){
				signalFinishedPlayingInTestingRound();
			} else{
				setTimeout("nextRound()",1000);
				}
			break;
		case "Reproduction":
			setTimeout("nextRound()",1000);
			break;
		case "ReproduceTraining":
			showMe("SlideWhistle");
			showMe("ListenAgain");
			startRecord();

			break;
		default:
			break;
	}

}

// losing window focus can cause problems, so we keep track of it
$(window).blur(function() {
	windowHasLostBlur = true;
});


// function getQueryParams(qs) {
// 		qs = qs.split("+").join(" ");
//
// 		var params = {}, tokens,
// 			re = /[?&]?([^=]+)=([^&]*)/g;
//
// 		while (tokens = re.exec(qs)) {
// 			params[decodeURIComponent(tokens[1])]
// 				= decodeURIComponent(tokens[2]);
// 		}
//
// 		return params;
// 	}

// function checkTestRun(){
// 	var experParams = getQueryParams(document.location.search);
// 	if(test in experParams["test"]){
// 		testRun = true;
//
// 	}
// }

function participantFailedToLearnAnythingWithinAllotedTime(){
	clearScreen();
	saveResults(); // save trial results (but not output language)
	cancelExperiment();
	finishedExperiment = true;
	showCode();
}

function runOutOfTime(){

	cancelExperiment();
	clearScreen();
	finishedExperiment = true;
	setInstruction("The experiment ended due to a time out (more than 4 hours).");

}

function tellClientTheServerIsBusy(){
	clearScreen();
	setInstruction(serverBusyMessage);
	showMe("instructions");
	setBigInstruction("");
	hideMe("BigInstructions");
	setTimeout('hideMe("BigInstructions")',1000);
}



function ipAddressHasDoneThisExperBefore(doneBefore){
	if(doneBefore && (!testRun) && denyParticipantIfIPAddressAlreadyLogged){
		// TODO: finish
		clearScreen();  // gets rid of arrows.
		setBigInstruction("");
		setInstruction(denyParticipantIfIPAddressAlreadyLogged_MESSAGE);
		showMe("instructions");
	} //else{
//		getExperimentData();  // from talkToServer.js (then calls getTrainingData)
	//}
}

function tellClientAudioNotWorking(){
	clearScreen();
	setInstruction(audioNotWorking_MESSAGE);
	showMe("instructions");
	setBigInstruction("");
	hideMe("BigInstructions");
	setTimeout('hideMe("BigInstructions")',1000);
}

window.onbeforeunload = function (e) {
		if(!finishedExperiment){
	    e = e || window.event;

	    // For IE and Firefox prior to version 4
	    if (e) {
	        e.returnValue = 'Are you sure you want to leave this page?';
	    }

	    // For Safari
	    return 'Are you sure you want to leave this page?';
	}
};

function showStartMessage(){
  setBigInstruction(startMessage);
}


// TODO: cancel experiment in log file if leave page?
// window.onunload = function(e){
// 	cancelExperiment();
// }
