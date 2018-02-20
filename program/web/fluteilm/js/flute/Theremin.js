function Theremin(audioContext) {
	// TODO make more things not use this.
	var oscillatorNode = audioContext.createOscillator();
	oscillatorNode.start(0);

	var gainNode = audioContext.createGain();
	var playing = false;
	var volume = 0.05;

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
			this.setVolume(volume);
			playing = true;
		}
	};

	this.connectGainNode = function(){
		oscillatorNode.connect(gainNode);
	};

	this.disconnectGainNode = function(){
		oscillatorNode.disconnect(gainNode);
	};

	this.turnOff = function(){
		if(playing){
			this.setVolume(0);
			playing = false;
		}
	};

	this.setFrequency = function(v) {
		oscillatorNode.frequency.value = v;
		this.frequency = v;
	};
	
	this.setVolume = function(v) {
		gainNode.gain.value = v;
	};

	this.connect = function(output) {
		gainNode.connect(output);
	};	
	
	this.setPitchBend = function(v) {
		// update physical position (between 0 and 1)
		this.physicalPosition = v;

		// double sigmoid and bark transform
		this.frequency = this.physicalPosToHz(v);

		// here we could do equal loudness stuff..
		this.setVolume(volume);
		oscillatorNode.frequency.value = this.frequency;
	};	

	//
	// non-linear flute stuff
	//

	// constants
	var pitchMin = 200;
	var pitchMax = 6000;

	var shift = 0.4;
	var range = 0.4;

	var tan_h = Math.atan(-2.5) + Math.pow(10,-14);
	var tan_steepness = 0.5;
	var tan_width = 2.6;
	var tan_heigth = 5;

	// function definitions

	this.setCurvature = function(curv){
		m_curvature = tan_heigth + Math.tan(curv * tan_width + tan_h) / tan_steepness;
		sMin = this.f_double_sigmoid2(0);
		sMax = this.f_double_sigmoid2(1);
	};

	this.f_to_bark = function(f) {
		return 26.81 / (1 + (1960 / f)) - 0.53;
	};

	this.f_to_freq = function(b) {
		return 1960 / (26.81 / (b + 0.53) - 1);
	};

	this.f_sigmoid = function(x) {
		return Math.exp(m_curvature*(x)) / (1 + Math.exp(m_curvature*(x)));
	};

	this.f_align = function(x) {
		return 2*(x-shift)/range;
	};

	this.f_double_sigmoid = function(x) {
		var raw_sigmoid = this.f_double_sigmoid2(x);
		return((raw_sigmoid-sMin) / (sMax-sMin));
	};

	this.f_double_sigmoid2 = function(x){
		return(((this.f_sigmoid(this.f_align(x)+1) + this.f_sigmoid(this.f_align(x)-1))) * 0.5);
	};

	this.physicalPosToHz = function(v){
		var norm_sigmoid = this.f_double_sigmoid(v);

		// transform domain from sigmoid to barks
		var bark_min = this.f_to_bark(pitchMin);
		var bark_max = this.f_to_bark(pitchMax);
		var bark_sigmoid = norm_sigmoid*(bark_max-bark_min)+bark_min;

		// inverse transformed barks to hz
		return(this.f_to_freq(bark_sigmoid));
	};

	return this;
}
