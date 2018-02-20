function Theremin(audioContext) {
	// TODO make more things not use this.
	var oscillatorNode = audioContext.createOscillator();
	oscillatorNode.start(0);

	var gainNode = audioContext.createGain();
	var playing = false;

	this.pitchBase = 300;
	this.pitchMax = 1000;
	this.maxVolume = 0.25;

	this.thereminVolume = 0.1;

	this.frequency = 0;
	this.physicalPosition = -1;

	this.togglePlaying = function() {
		if(playing) {
			oscillatorNode.disconnect(gainNode);
		} else {
			oscillatorNode.connect(gainNode);
		}
		playing = !playing;
		return playing;
	};

	this.turnOn = function(){
		if(!playing){
			oscillatorNode.connect(gainNode);
			playing = true;
		}
	}

	this.turnOff = function(){
		if(playing){
			oscillatorNode.disconnect(gainNode);
			playing = false;
		}
	}

	this.setFrequency = function(v) {
		oscillatorNode.frequency.value = v;
		this.frequency = v;
	}

	//
	// non-linear flute stuff
	//

	// constants
	var pitchMin = 200;
	var pitchMax = 6000;

	var shift = 0.5;
	var range = 0.5;

	var tan_h = Math.atan(-2.5) + Math.pow(10,-14)
	var tan_steepness = 0.5
	var tan_width = 2.6
	var tan_heigth = 5

	this.m_curvature = 0;


	var sMin = 0;//this.f_double_sigmoid(0);  // TODO: move outside this function?
	var sMax = 1;//this.f_double_sigmoid(1);

	// function definitions

	this.setCurvature = function(curv){
		console.log("Set curvature "+curv);
		this.m_curvature = tan_heigth + Math.tan(curv * tan_width + tan_h) / tan_steepness;
		sMin = this.f_double_sigmoid2(0);  // TODO: move outside this function?
		sMax = this.f_double_sigmoid2(1);
	}

	this.f_to_bark = function(f) {
		return ((26.81 * f) / (1960 + f)) - 0.53;
	}

	this.f_to_freq = function(b) {
		return -((490 * (100 * b + 53))/(25 * b - 657));
	}

	this.f_sigmoid = function(x) {
		return Math.exp(this.m_curvature*(x)) / (1 + Math.exp(this.m_curvature*(x)));
	}

	this.f_align = function(x) {
		return 2*(x-shift)/range;
	}

	this.f_double_sigmoid = function(x) {
		var raw_sigmoid = this.f_double_sigmoid2(x);
		return((raw_sigmoid-sMin) / (sMax-sMin));
	}

	this.f_double_sigmoid2 = function(x){
		return(((this.f_sigmoid(this.f_align(x)+1) + this.f_sigmoid(this.f_align(x)-1))) * 0.5);
	}

	this.physicalPosToHz = function(v){
		sMin = this.f_double_sigmoid2(0);  // TODO: move outside this function?
		sMax = this.f_double_sigmoid2(1);
		//var raw_sigmoid = this.f_double_sigmoid(v);
		//var norm_sigmoid = (raw_sigmoid-sMin) / (sMax-sMin);

		var norm_sigmoid = this.f_double_sigmoid(v);

		// transform domain from sigmoid to barks
		var bark_min = this.f_to_bark(pitchMin);
		var bark_max = this.f_to_bark(pitchMax);
		var bark_sigmoid = norm_sigmoid*(bark_max-bark_min)+bark_min;

		// inverse transformed barks to hz
		return(this.f_to_freq(bark_sigmoid))
	}

	this.setPitchBend = function(v) {
		// update physical position (between 0 and 1)
		this.physicalPosition = v;

		this.frequency = this.physicalPosToHz(v);

		// here we could do equal loudness stuff..
		this.setVolume(this.thereminVolume);
		//console.log([v,this.frequency,this.thereminVolume]);
		oscillatorNode.frequency.value = this.frequency;
	};

	this.setVolume = function(v) {
		//gainNode.gain.value = v * this.maxVolume;
		gainNode.gain.value = v;
	};

	this.connect = function(output) {
		gainNode.connect(output);
	};

	this.setCurvature(0);
	this.setVolume(this.thereminVolume);
	return this;
}
