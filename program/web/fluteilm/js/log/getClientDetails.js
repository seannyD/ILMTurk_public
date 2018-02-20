
function writeClientDetails(){
	var details = getClientDetails();
	writeDataToServer(details,'partDetails/'+outputFileName);
}

function getClientDetails(){
	var nVer = navigator.appVersion;
	var nAgt = navigator.userAgent;
	var browserName  = navigator.appName;
	var fullVersion  = ''+parseFloat(navigator.appVersion);
	var majorVersion = parseInt(navigator.appVersion,10);
	var nameOffset,verOffset,ix;

	// In Opera, the true version is after "Opera" or after "Version"
	if ((verOffset=nAgt.indexOf("Opera"))!=-1) {
	 browserName = "Opera";
	 fullVersion = nAgt.substring(verOffset+6);
	 if ((verOffset=nAgt.indexOf("Version"))!=-1)
	   fullVersion = nAgt.substring(verOffset+8);
	}
	// In MSIE, the true version is after "MSIE" in userAgent
	else if ((verOffset=nAgt.indexOf("MSIE"))!=-1) {
	 browserName = "Microsoft Internet Explorer";
	 fullVersion = nAgt.substring(verOffset+5);
	}
	// In Chrome, the true version is after "Chrome"
	else if ((verOffset=nAgt.indexOf("Chrome"))!=-1) {
	 browserName = "Chrome";
	 fullVersion = nAgt.substring(verOffset+7);
	}
	// In Safari, the true version is after "Safari" or after "Version"
	else if ((verOffset=nAgt.indexOf("Safari"))!=-1) {
	 browserName = "Safari";
	 fullVersion = nAgt.substring(verOffset+7);
	 if ((verOffset=nAgt.indexOf("Version"))!=-1)
	   fullVersion = nAgt.substring(verOffset+8);
	}
	// In Firefox, the true version is after "Firefox"
	else if ((verOffset=nAgt.indexOf("Firefox"))!=-1) {
	 browserName = "Firefox";
	 fullVersion = nAgt.substring(verOffset+8);
	}
	// In most other browsers, "name/version" is at the end of userAgent
	else if ( (nameOffset=nAgt.lastIndexOf(' ')+1) <
			  (verOffset=nAgt.lastIndexOf('/')) )
	{
	 browserName = nAgt.substring(nameOffset,verOffset);
	 fullVersion = nAgt.substring(verOffset+1);
	 if (browserName.toLowerCase()==browserName.toUpperCase()) {
	  browserName = navigator.appName;
	 }
	}
	// trim the fullVersion string at semicolon/space if present
	if ((ix=fullVersion.indexOf(";"))!=-1)
	   fullVersion=fullVersion.substring(0,ix);
	if ((ix=fullVersion.indexOf(" "))!=-1)
	   fullVersion=fullVersion.substring(0,ix);

	majorVersion = parseInt(''+fullVersion,10);
	if (isNaN(majorVersion)) {
	 fullVersion  = ''+parseFloat(navigator.appVersion);
	 majorVersion = parseInt(navigator.appVersion,10);
	}

	var windowW = window.innerWidth;
	var windowH = window.innerHeight;
	var swHeight = document.getElementById('SlideWhistle').clientHeight;
	var swWidth = document.getElementById('SlideWhistle').clientWidth;

	// var details = (''
	//  +'Browser name  = '+browserName+'\n'
	//  +'Full version  = '+fullVersion+'\n'
	//  +'Major version = '+majorVersion+'\n'
	//  +'navigator.appName = '+navigator.appName+'\n'
	//  +'navigator.userAgent = '+navigator.userAgent+'\n'
	//  +'turker.code = ' + turkerCode+'\n'
	// )



	var OSName="Unknown OS";
	if (navigator.appVersion.indexOf("Win")!=-1) OSName="Windows";
	if (navigator.appVersion.indexOf("Mac")!=-1) OSName="MacOS";
	if (navigator.appVersion.indexOf("X11")!=-1) OSName="UNIX";
	if (navigator.appVersion.indexOf("Linux")!=-1) OSName="Linux";

	var mstring = "";
	for(var i=0;i<meanings.length;++i){
		mstring += meanings[i]+"#";
	}

	var details = "Browser\tVersion\tMajorVersion\tappName\tuserAgent\tOS\tturkerCode\twindowW\twindowH\tswW\tswH\tmeaningsOrder\tgender\tage\tnativeLang\tSONA\n";
	details += [browserName,fullVersion,majorVersion,
				navigator.appName,navigator.userAgent, OSName,
				turkerCode, windowW, windowH, swWidth, swHeight, mstring,
			participantGender,participantAge,participantNativeLanguage,participantSONAID].join("\t");
	return(details);
	}
