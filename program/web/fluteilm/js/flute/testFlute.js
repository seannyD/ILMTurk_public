function testTheremin(){
  audioContext2 = new AudioContext();
  theremin2 = new Theremin(audioContext2);
  theremin2.connect( audioContext2.destination );
  theremin2.setFrequency(0);
  theremin2.turnOff();
	// given a Hz, what should the physical position be?

  var curx = [0.0,0.1,0.2,0.3,0.4,0.5];

  var out = "";
  for(var c=0;c<curx.length;++c){
  	conversionTableHz = [];
  	conversionTablePhysical = [];
    theremin2.setCurvature(curx[c]);
  	// go through a list of physical positions,
  	for(var i=0; i <= conversionTableResolution; ++i){
  		var physpos = (1 / conversionTableResolution)*i;
  		var hzx = theremin2.physicalPosToHz(physpos);
      out += hzx +"," + physpos + ","+curx[c]+"<br />";

  	}

  }

document.getElementById("TestResults").innerHTML = out;

}
