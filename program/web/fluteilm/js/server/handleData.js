// handle data coming in from the server

// global values for experiment details
chainNum = 0;
genNum = 0;
signals = [];  // signals is in interface
trainingSignals = [];
// meanings defined in parameters
outputFileName = "xxx";
curvature = 0;
results = [];
mappingFromSignalsToMeanings = [];


var testRun = false;
var SONAExperiment = false;

function recieveData(data){
	// receive experiment data from server
	console.log("Recieved data");
	console.log(data);

	// data.busy is a field with a boolean
	// if true, then no slots are availabe right now
	if(data.busy){
		tellClientTheServerIsBusy();
	} else{

	chainNum = data.chainNum;
	genNum = data.genNum;
	signals = parseSignalString(data.signals);

	signals = signals.slice(0,numMeanings);

	// First generation can be in physical space.  Otherwise, treat signals as frequencies
	if(firstGenerationSignalsAreInLinearPhysicalSpace && genNum=="1"){
		signals = convertSignalsFromLinearPhysicalSpace(signals);
	}

	curvature = data.curvature;
	if(data.curvature===false){
		console.log("Curvature wrong format, setting to zero");
		curvature = 0;
	}

	if(shuffleMappingBetweenSignalsAndMeanings){ // variable in parameters.js
		shuffleSignalOrder();
	}

	// set curavture of flute
	theremin.setCurvature(parseFloat(curvature));
	// make table to convert hz to physical position
	makeConversionTables();


	outputFileName = data.outputFileName;

	preloadImages();




	getTrainingData(); // _______
	}//							|
//								|
}//								|
//								v
function recieveTrainingData(data){
	console.log(data);
	trainingSignals = parseSignalString(data.contents);

	trainingSignals = trainingSignals.slice(0,numMeanings);

	setUpRoundOrder(); // in interface.js
	checkTestExperiment();  // if we're just testing, then use a simple results file name
	checkExperimentOptions();  // in instructions.js

	// This makes it possible to move on if we get the data only after they press 'ok'
	setTimeout("nextRound()",1000);
}

function parseSignalString(s){
	console.log(s);
	if(! (typeof s === 'string' )) {
    return(s);
	}

	var sx = s.split("\n");
	sig = [];
	for(i = 0; i< sx.length; ++ i){
		if(sx[i].length > 0){
			nums = sx[i].split(",");
			numslist= [];
			for(n = 0; n < nums.length; ++ n){
				numslist.push(parseInt(nums[n]));
			}
			sig.push(numslist);
		}
	}
	console.log(sig);
	return(sig);
}

function convertSignalsFromLinearPhysicalSpace(signalsP){
	var signalsFreq = [];
	theremin.setCurvature(0);
	for(var i=0;i<signalsP.length; ++i){
		var signalP = signalsP[i];
		var signalF = [];
		for(var j=0;j< signalP.length; ++ j){
			signalF.push(theremin.physicalPosToHz(signalP[j]/1000));
		}
		signalsFreq.push(signalF);
	}
	theremin.setCurvature(curvature);
	return(signalsFreq);
}

function saveData(){
	console.log("SaveData");

	saveOutputLang();
	saveResults();
}

function saveOutputLang(){
	outString = "";
	for(var i=0;i<lastReproductionSignals.length;++i){
		outString += lastReproductionSignals[i].join(",")+"\n";
	}
	writeDataToServer(outString,'outputLanguages/'+outputFileName);
}

function saveResults(){
	resultsString = "";
	for(var i=0;i<results.length;++i){
		for(var j=0;j<results[i].length;++j){
			if(Array.isArray(results[i][j])){
				resultsString += results[i][j].join(",")+"\t";
			} else{
				resultsString += results[i][j]+"\t";
			}
		}
		resultsString += "\n";
	}

	writeDataToServer(resultsString,'results/'+outputFileName);
}

function getQueryParams(qs) {
		qs = qs.split("+").join(" ");

		var params = {}, tokens,
			re = /[?&]?([^=]+)=([^&]*)/g;

		while (tokens = re.exec(qs)) {
			params[decodeURIComponent(tokens[1])]	= decodeURIComponent(tokens[2]);
		}

		return params;
	}

function checkTestExperiment(){
	var experParams = getQueryParams(document.location.search);
	console.log(experParams);
	// if the web address is something like
	// http://localhost/ILMTurk/web/fluteilm/index.html?test=t
	// then set some parameters to be in test mode
	if("test" in experParams){
		console.log("Test Experiment");
		testRun = true;

		//outputFileName = "testExperiment.txt";
	//	passLearningPhase_ProportionCorrectResponses = 0.25;
//		passLearningPhase_NumberOfRoundsBack = 4;

		if(cancelExperimentImmedatelyInTestMode){
			cancelExperiment();
		}

//		roundOrder[1] = "Reproduction";
//		roundStims[1] = 0;

		if("curvature" in experParams){
			curvature = parseFloat(experParams["curvature"]);
			theremin.setCurvature(parseFloat(curvature));
			console.log("Set Curvature ",curvature);
		}
	}
}




function shuffleSignalOrder(){
	// This method actually mixes up the signal order, but we would rather
	// just change the image stimuli order
	// var sorder = [];
	// for(var i=0; i < signals.length; ++i){
	// 	sorder.push(i);
	// }
	// shuffle(sorder);
	// mappingFromSignalsToMeanings = sorder;
	// var newSig = [];
	// for(var i =0;i<signals.length; ++i){
	// 	newSig.push(signals[sorder[i]]);
	// }
	// signals = newSig;
	shuffle(meanings);
}
