// Changes:
//	assigning functions to mouse/touch events moved to initPage()
//	start() and stop() renamed to startSlideWhistle() and stopSlideWhistle() to avoid name conflicts in other files.
// 	swapped hard-coded value for minimumRecordLength variable which affects saveRecording();
//	added if(oscillator!=null) to record()
//	reinstated touchleave -> noteOff.  Alternatively, add a listener to the whole document that calls noteOff() after any mouseup or touchend and when noteNowOn
//	added 	exper_EndPlayback(); to call funciton in exper.js
//	stopRecord(): juding whether signal is long enough is now handled in exper.js

// vertical slider?
var verticalSlider = true;

var	audiodev;
//var oscillator;

// These are now in Theremin.js
//var upperFreq = 1760;// Even higher A :)
//var lowerFreq = 440; // High A
//var freqRange = (upperFreq - lowerFreq);

var noteNowOn = false;
var fadeOut = false;

var fadeWindow = 4; //number of samples to fade in/out when playing back

//var toneChangeIntervalId = 0;

var recording = false;
var recordBuffer = Array();
var physicalBuffer = Array();
var recordRate = 50;  // number of milliseconds between samples
var recordIntervalId = 0; // just initialising this
// old system to make sure samples are evenly spaced (not implemented)
var lastRecordTime = 0;
var maxDelayTime = recordRate*1.5;
var minDelayTime = recordRate*0.5;

var playingBack = false;
var playbackIntervalId = 0;
var playbackPos = 0;
var playbackInterpolate = false;

var sliderWidth = 100;
var sliderHeight = 500;
var sliderX = 0;
var sliderY = 0;

//theremin
var audioContext, jsNode, theremin;

var bufferPadding = Array();

for(var i=0;i<10;++i){
	bufferPadding.push(0);
}

// visual stimulus

var showNodeInSlider = false;
var slideWhistleNodeHeight = 100;

var conversionTableHz = [];
var conversionTablePhysical = [];
var conversionTableResolution = 3000;
/////



function initPage(){
	// can't call immediately because page may not be loaded


	audioContext = new AudioContext();
	theremin = new Theremin(audioContext);
	theremin.connect( audioContext.destination );
	theremin.setFrequency(0);
	theremin.turnOff();

	document.getElementById("SlideWhistle").addEventListener("mousemove",toneChange, false);
	document.getElementById("SlideWhistle").addEventListener("mousedown",noteOn, false);
	document.getElementById("SlideWhistle").addEventListener("mouseup",noteOff, false);
	document.getElementById("SlideWhistle").addEventListener("mouseleave",noteOff, false);

	// for android tablet:
	document.getElementById("SlideWhistle").addEventListener("touchmove",toneChange, false);
	document.getElementById("SlideWhistle").addEventListener("touchstart",noteOn, false);
	document.getElementById("SlideWhistle").addEventListener("touchend",noteOff, false);
	document.getElementById("SlideWhistle").addEventListener("touchleave",noteOff, false);

	//oscillator = null;

	calibrateSlider();
	}

	function calibrateSlider(){
		var showFirst = document.getElementById("SlideWhistle").style.display == "none";
		var showFirstNode = document.getElementById("SlideWhistleNode").style.display == "none";
		if(showFirst){
			showMe("SlideWhistle");
		}
		if(showFirstNode){
			showMe("SlideWhistleNode");
		}
		sliderWidth = document.getElementById("SlideWhistle").offsetWidth;
		sliderHeight = document.getElementById("SlideWhistle").offsetHeight;
		sliderX = document.getElementById("SlideWhistle").offsetLeft;
		sliderY = document.getElementById("SlideWhistle").offsetTop;
		slideWhistleNodeHeight = document.getElementById("SlideWhistleNode").height;
		if(showFirst){
			hideMe("SlideWhistle");
		}
		if(showFirstNode){
			hideMe("SlideWhistleNode");
		}
		console.log(["Recalibrate",sliderWidth,sliderHeight,sliderX,sliderY,slideWhistleNodeHeight]);
	}

// make sure the slide whistle is recalibrated after resize
	window.onresize = function(event) {
			calibrateSlider();
	};

function startSlideWhistle(){
	//theremin.turnOn();
	if(document.getElementById("SlideWhistle").style.display=="inline"){
		calibrateSlider();
	}
	theremin.connectGainNode();
	}

function stopSlideWhistle(){
	//theremin.turnOff();
	theremin.disconnectGainNode();
	}


function setFrequency(f){
	theremin.setPitchBend(f); // expects value from 0 to 1
}

function record(){
//	var dx = new Date();
//	var now = dx.getTime();
//	console.log(now - lastRecordTime);
//	if((now - lastRecordTime) < maxDelayTime & (now - lastRecordTime)> minDelayTime){

		recordBuffer.push(Math.round(theremin.frequency));
		physicalBuffer.push(Math.trunc(theremin.physicalPosition*1000));
//	}
//	lastRecordTime = now;

// 	if(oscillator!=null){
// 		recordBuffer.push(Math.round(oscillator.frequency));
// 	}
}

function playSavedRecording(s){
		// TODO
}

function recordBufferToString(){
	// convert recordBuffer to a string
	// there may be a more sensible way to do this
//	console.log("RECORD BUFFER");
//	console.log(recordBuffer);
	return(recordBuffer.join());
}

function stringToRecordBuffer(s){

	// split the string
	var sp = s.split(",");

	// convert each element to a number
	var ret = Array();

	for(var i=0;i<sp.length;++i){
		ret.push(parseInt(sp[i]));
	}
//	console.log("string to record buffer");
//	console.log(ret);
	return(ret);
}

function startRecord(){

	if(recording){
		clearInterval(recordIntervalId);
	}
	recording = true;
	recordBuffer = new Array();
	physicalBuffer = new Array();
//	var dx = new Date();
//	lastRecordTime = dx.getTime();
	theremin.setFrequency(0);
	theremin.physicalPosition = 0;
	//console.log("START RECORD");
	recordIntervalId = setInterval("record()",recordRate);
}

function stopRecord(){
	clearInterval(recordIntervalId);
	saveRecording();
}

function trimArray(targetArray){

  var ax = Array();
	for(var i=0; i < targetArray.length; ++i){
		ax.push(targetArray[i]);
	}

	var startPos = ax.length;
	var endPos = ax.length;
	// trim silence at start and end
	for(var i=0; i < ax.length;++i){
		if(ax[i]>0){
			startPos = i;
			i = ax.length +1;
		}
	}
	for(var i=ax.length-1; i > startPos; --i){
		if(ax[i]>0){
			endPos = i;
			i = startPos-1;//escape loop
		}
	}

	return(ax.slice(startPos,endPos));
}

function saveRecording(){
	recordBuffer = trimArray(recordBuffer);
	physicalBuffer = trimArray(physicalBuffer);
//	console.log(recordBuffer);
//	console.log(physicalBuffer);
}

function startPlayback(){
//	console.log("startPlayback");
	playbackPos = 0;
	noteNowOn = true;
	var x = 0;
	if(recordBuffer.length>0){
		x = recordBuffer[0];
	}
	theremin.setFrequency(x);
	//theremin.turnOn();
	theremin.connectGainNode();
	//startSlideWhistle();  // now handled from outside
	//volume = 0;
	playingBack = true;
	playbackIntervalId =  setInterval("playback()",recordRate);
	fadeOut = false;
}

function playback(){
//	console.log(["playback",playbackPos, recordBuffer.length,bufferPadding.length]);
	if(playbackPos<recordBuffer.length){
		if(recordBuffer[playbackPos]==0){
			theremin.turnOff();

			hideMe("SlideWhistleNode");
		}
		else{
			theremin.setFrequency(recordBuffer[playbackPos]);
			theremin.turnOn();
			if(showNodeInSlider){
				showMe("SlideWhistleNode");
				setSliderNode(physicalBuffer[playbackPos]/1000);
			}
		}
		playbackPos += 1;
		//console.log(oscillator.frequency);

	}
	else{
		// end of the playback, clear interval
		//oscillator.frequency = 0;
		endOfPlayback();
	}

}

function startPlaybackWithNode(){
	showNodeInSlider = true;
	// TODO: replace this with recalibrate function
	calibrateSlider();
	//console.log("SliderWidth",sliderWidth, slideWhistleNodeHeight);
	startPlayback();
}

function endOfPlayback(){
//	console.log("endOfPlayback");
	// is called when the playback finishes
	clearInterval(playbackIntervalId);
	//theremin.turnOff();
	theremin.disconnectGainNode();
	theremin.setFrequency(0);
	playingBack = false;
	noteNowOn = false;
	showNodeInSlider = false;
	exper_EndPlayback();
}

function toneChange(event){

//	document.getElementById("reading2").value = noteNowOn;
	if(	noteNowOn && (event !== undefined) && (!playingBack)){
		// disable context menu
		disableContextMenu(event);
		setFrequency(calcSetFreq(event));
		}

}


function calcSetFreq(event){
	if(verticalSlider){
			//console.log(["calcSetFreq",sliderY,sliderHeight]);
			var yy = getYPos(event)-sliderY;
			if(yy>sliderHeight){
				yy = sliderHeight;
				}
			if(yy < 0){
				yy = 1
			}
			return( 1 - (yy / sliderHeight));
		}
		else{
			var xx = getXPos(event)-sliderX;
			if(xx>sliderWidth){
				xx = sliderWidth;
			}
			if(xx < 0){
				xx = 1
			}
			return(xx / sliderWidth);
			}
}

function getXPos(event){
	// disable context menu
	disableContextMenu(event);
	var xpos = 0;
	if(event.touches !== undefined){
			// we're on a tablet
				xpos = event.touches[0].pageX;
	}
	else{
			// we're on a computer
				xpos = event.clientX;
	}
	return(xpos);
}

function getYPos(event){
	// disable context menu
	disableContextMenu(event);
	var xpos = 0;
	if(event.touches !== undefined){
			// we're on a tablet
				xpos = event.touches[0].pageY;
	}
	else{
			// we're on a computer
				xpos = event.clientY;
	}
	return(xpos);
}




function noteOn(event){

	// disable context menu
	//disableContextMenu(event);
	noteOn_experHook(event);
	if(!playingBack && !noteNowOn){
		//fadeIn = true;
		noteNowOn = true;
		theremin.turnOn();
		//volume = 0.001;
		//startSlideWhistle();  // now handled from outside
		setFrequency(calcSetFreq(event));
	}
}

function noteOff(){

	if(!playingBack && noteNowOn){

		noteNowOn = false;
		fadeOut = true;
		theremin.setFrequency(0);
		theremin.turnOff();
		theremin.physicalPosition = -1;
		//oscillator.frequency = 0;

		// in some experiments, signal should be sent when participant lifts finger
		// see exper2.js
		setTimeout("noteOff_experHook()",10);

	}
}


function disableContextMenu(event){
	var e = event || window.event;
      e.preventDefault && e.preventDefault();
      e.stopPropagation && e.stopPropagation();
      e.cancelBubble = true;
      e.returnValue = false;
}

function setSliderNode(pos){
	// pos should be between 0 and 1
	pos = 1-pos;
	var physNodePos = (pos *  (sliderHeight-slideWhistleNodeHeight));
	document.getElementById("SlideWhistleNode").style.top = physNodePos+"px";
}

initPage();



function listIncludes(l,x){
	for(var i=0;i<l.length;++i){
		if(l[i]==x){
			return(true);
		}
	}
	return(false);
}

function makeConversionTables(){
	// given a Hz, what should the physical position be?
	conversionTableHz = [];
	conversionTablePhysical = [];
	// go through a list of physical positions,
	for(var i=0; i <= conversionTableResolution; ++i){
		var physpos = (1 / conversionTableResolution)*i;
		// get Hz, then add to dictionary
		var hzx = theremin.physicalPosToHz(physpos);
	//	if(!listIncludes(conversionTableHz,hzx)){
			conversionTableHz.push(hzx);
			conversionTablePhysical.push(physpos);
	//	}
	}
	// assumes monotonic function
//	conversionTableHz.sort();
//	conversionTablePhysical.sort();
	console.log("CONVERSTION TABLE");
	console.log(conversionTableHz);
	console.log(conversionTablePhysical);
}

function hzToPhysicalFromConverstionTable(hzx){
	if(hzx==0){
		return(0);
	}
	// requires makeConverstionTables() to be run first

	var physpos = 0;
	var outpos = 0;
	// go through the list until we find a value bigger than the target
	for(var i=0;i<conversionTableHz.length;++i){
		if(conversionTableHz[i] > hzx){
			// work out the hz above and below the target
			if(i==0){
				outpos= conversionTablePhysical[0];
			} else{
				var nextPos = conversionTablePhysical[i];
				var prevPos = conversionTablePhysical[i-1];

				var nextHz = conversionTableHz[i];
				var prevHz = conversionTableHz[i-1];
				// the proportion of distance between the target and the prev value
				var gapHz =(nextHz-hzx)/(nextHz - prevHz);

				// linear interpolation
				var outpos = prevPos + (gapHz * (nextPos-prevPos));
				//console.log([hzx,nextPos,prevPos,nextHz,prevHz,gapHz,outpos]);
			}
			return(outpos);
		}
	}
	return(1);
}
