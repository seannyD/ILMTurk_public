
var learningProgress = [];

var learningRoundCount = 0;
var learningRoundState = "Learning";  // Learning or Testing

var numberOfLearningPhases = 0;
// var maximumNumberOfLearningPhases = 12;  // Now set in parameters.js

var testing_stimOrder = [];
var learning_stimOrder = [];

var numberOfGuessCandidates = 3;  // actually just overridden by number of meanings
var candidateOrder = [];

var currentTarget = 0;

//
// -          Learning/testing. This repeats until testing yields 100% accuracy. (Justification: We want to rule out participants don't remember stuff (cognitive bias). We are merely interested if they prefer certain region in the articulator (anatomical bias). We have meanings and learning of meanings because we want to prevent signal collapse. Meanings are a natural requirement for expressivity.)
//
// o   Learning: participants get presented with four meanings in random order (e.g., greebles: https://en.wikipedia.org/wiki/Greeble_%28psychology%29) and corresponding sounds.

function initLearningPhase(){
	if(numberOfGuessCandidates>numMeanings){
		numberOfGuessCandidates = numMeanings;
	}
	testing_stimOrder = [];
	for(var i =0; i < meanings.length; ++i){
		testing_stimOrder.push(i);
		learning_stimOrder.push(i)
	}
	shuffle(testing_stimOrder);
	shuffle(learning_stimOrder);
}


function passedLearningPhase(){

	if(testing_stimOrder.length==0){
		initLearningPhase();
	}

	if(learningProgress.length<passLearningPhase_NumberOfRoundsBack){
		return(false);
	}

	if((learningProgress.length % meanings.length) !=0){
		// not at the end of a training phase
		return(false);
	}

	if(numberOfLearningPhases >= maximumNumberOfLearningPhases){
		// participant has done enough training
		setTimeout("participantFailedToLearnAnythingWithinAllotedTime()",2000);
		return(true);
	}

	var evaluate = learningProgress.slice(learningProgress.length-passLearningPhase_NumberOfRoundsBack,learningProgress.length);
	var tot = 0;
	for(var i=0; i<evaluate.length; ++i){
		tot += evaluate[i];
	}
	console.log("Evaluate");
	console.log(evaluate);
	console.log(tot);
	return(tot >= (passLearningPhase_ProportionCorrectResponses* evaluate.length));

}

function learningPhase(){
	// switch between learning and testing

	var failMessage = false;

	if(learningRoundCount>=meanings.length){
		if(learningRoundState=="Learning"){
			learningRoundState = "Testing";
			// shuffle order of testing stimuli
			shuffle(testing_stimOrder);
		} else {
			learningRoundState = "Learning";
			shuffle(learning_stimOrder);
			numberOfLearningPhases += 1;
			// TODO: Add message about failure of learning phase
			failMessage = true;
			setInstruction(failedLearningPhase_MESSAGE);

		}
		learningRoundCount = 0;
	}

	if(failMessage){
		setTimeout("nextLearningRound();",4000);
	} else {
		if(learningRoundCount==0){
			setTimeout("nextLearningRound();",2000);
		} else{
			nextLearningRound();
		}
	}

}

function nextLearningRound(){
	// start learning or testing round
	if( learningRoundState =="Learning"){
			learningRound(learningRoundCount);
	} else{
			testingRound();
			}
	learningRoundCount += 1;
}


function learningRound(meaningId){

	numToPlay = learning_stimOrder[meaningId];

	console.log("Learning Round ",meanings[numToPlay]);
	// single stimulus shown
	setImage("imageStimulusIMG",meanings[numToPlay]);
	showMe("imageStimulus");
	setInstruction("Listen!");
	playSignal(signals[numToPlay]);
}

//
// o   Testing: Participants get presented with four sounds in random order. They have to select a meaning (1 out of 4) randomly positioned on the screen (the meaning context) and get feedback whether it was correct.


function testingRound(){

	var allMeanings = [];
	for(var i =0;i<meanings.length;++i){
		allMeanings.push(i);
	}

	// target (keep as variable, because learningRoundCount can change
	currentTarget = allMeanings[testing_stimOrder[learningRoundCount]];
	console.log("Test round "+currentTarget);
	// alternatives
	var candidates = [];
	for(var i =0;i<meanings.length;++i){
		if(i!=currentTarget){
			candidates.push(i);
			}
	}
	console.log(candidates);
	// choose a random set of alternative candidates
	shuffle(candidates);
	candidates.slice(0,numberOfGuessCandidates-1);
	console.log(candidates);
	// add target
	candidates.push(currentTarget);
	// shuffle order
	shuffle(candidates);
	console.log(candidates);
	candidateOrder = [];
	// fill guess options with candidates
	for(var i=0; i < numberOfGuessCandidates; ++ i){
		// option names and image names go from 1
		setImage("option"+(i+1),meanings[candidates[i]]);
		// keep track of which meaning is in which window, so we can retrieve the selected meaning
		candidateOrder.push(candidates[i]);
	}
	//setTimeout('showMe("guessPanel")',1000);
	playSignal(signals[currentTarget]);
	setInstruction("Listen and guess the right picture");
}


function signalFinishedPlayingInTestingRound(){
	setInstruction(learningPhase_test_MESSAGE);
	setTimeout('showMe("guessPanel")',500);
	setTimeout('showMe("ListenAgain")',500)
	waitingForInput=true;
}

function playerGuessedInLearningPhase(optionChosen){
	if(waitingForInput){
		waitingForInput = false;
		// optionChosen is the window number, so
		// look up which meaning this relates to
		optionChosen = candidateOrder[parseInt(optionChosen)];
		success = optionChosen == currentTarget;

		feedback(success);

		results.push([experiment_state,currentTarget,optionChosen,getTimestamp(),windowHasLostBlur,curvature, mappingFromSignalsToMeanings.join("_"), turkerCode]);
		windowHasLostBlur = false;

		if(success){
			learningProgress.push(1);
		} else{
			learningProgress.push(0);
		}

		setTimeout("nextRound();",2000);
	}
}

function feedback(success){
	if(success){
		setInstruction("Correct");
	} else{
		setInstruction("Incorrect");
	}
}
