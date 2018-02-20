// -          Reproduction: the four meanings get presented in random order. Participants have to reproduce the sound they just heard.

//reproductionSignals = [];
//reproductionMeanings = [];
currentReproductionMeaning = 0;
lastReproductionSignals = [];
var retryNumber = 0;

waitingForInput = false;

function reproductionRound(meaningId){
	setImage("imageStimulusIMG",meanings[meaningId]);
	showMe("imageStimulus");
	currentReproductionMeaning = meaningId;
	setInstruction(finalReproductionPhase_MESSAGE);
	setTimeout('showMe("SlideWhistle");',1000);
//	startSlideWhistle();
	retryNumber = 0;
	startSlideWhistle();
	startRecord();

}

function reproductionTrainingRound(meaningId){
	currentReproductionMeaning = meaningId;
	setInstruction(reproduceTheSignal_MESSAGE);
	setTimeout('showMe("SlideWhistle");',1000);
	if(canListenAgainInIntroduction){
		setTimeout('showMe("ListenAgain");',1000);
		//setTimeout('showMe("NextButton");'); // next button will appear after user has used slider
	}
	retryNumber = 0;
	startSlideWhistle();
	startRecord();
}

function noteOn_experHook(event){
	// user presses on slider
	if(!noteNowOn){
		// do something the first time this happens
		startSlideWhistle();
	}
}

function reproductionIsSuitable(signal){
	// todo: decide how to detect unsuitable signals

	if(experiment_state=="ReproduceTraining"){
		return("Yes");
	}

	var signalTime_milliseconds = signal.length * recordRate;
	if(signalTime_milliseconds > maxSignalLength_milliseconds){
			return("Too Long");
	}
	if(signalTime_milliseconds < minSignalLength_milliseconds){
		return("Too Short");
	}
	return("Yes");
}

function responseIfProductionIsNotSuitable(problem){
	//showMe("imageStimulus");

	switch(problem){
		case "Too Short":
			setInstruction(signalTooShort_MESSAGE);
			break;
		case "Too Long":
			setInstruction(signalTooLong_MESSAGE);
			break;
		default:
			setInstruction("Please Try again"); // shouldn't reach here
	}

	setTimeout('showMe("SlideWhistle");',1000);
	startRecord();
}

function noteOff_experHook(){
// user lifts finger
	stopRecord();

	if(experiment_state=="InitialInstruction" || experiment_state=="SliderRecap"){
		return(false);
	}

	hideMe("SlideWhistle");
	var suitable = reproductionIsSuitable(recordBuffer);
	if(suitable == "Yes"){

		setInstruction(reproduction_ContinueOrRetry_MESSAGE);

		// record results
		console.log("Push results");
		results.push([experiment_state,currentReproductionMeaning,recordBuffer,getTimestamp(),windowHasLostBlur,curvature,physicalBuffer, mappingFromSignalsToMeanings.join("_"), turkerCode, retryNumber]);
		windowHasLostBlur = false;
		retryNumber += 1;

		// update language
		lastReproductionSignals[currentReproductionMeaning] = recordBuffer;

		hideMe("imageStimulus");

		if(experiment_state=="Reproduction"){
			//reproductionMeanings.push(currentReproductionMeaning);
			//reproductionSignals.push(recordBuffer);
			//setTimeout("nextRound()",1000);

			// give the option of retrying or moving on
			showMe("RetryButton");
			showMe("NextButton");
			hideMe("SlideWhistle");
			showMe("imageStimulus");

		}
		if(experiment_state=="ReproduceTraining"){
			if(sliderRemainsUntilNextButtonInIntroduction){
				showMe("NextButton");
				showMe("SlideWhistle");
				startRecord();
			} else{
				setTimeout("nextRound()",1000);
			}
		}

	}  else {
		responseIfProductionIsNotSuitable(suitable);
	}

}

function pressRetryButton(){
	hideMe("RetryButton");
	hideMe("NextButton");
	if(experiment_state=="Reproduction"){
		startRecord();
		showMe("SlideWhistle");

	}
}
