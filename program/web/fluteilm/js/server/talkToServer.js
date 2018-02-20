

function getExperimentData(){
		// request experiment details from the server
		// on returning data, this will call 'recieveData'
		console.log("Requesting data");
	     $.ajax({
			   type: "POST",
			   url: "php/getExperimentData.php",
			   data: {
			   			'function': 'get-experiment',
						},
			   dataType: "json",
			   success: function(data){
						recieveData(data);
			  },
		 });

}

function getTrainingData(){
		console.log("Requesting training data");
	     $.ajax({
			   type: "POST",
			   url: "php/getTrainingData.php",
			   data: {
			   			'function': 'get-training',
						},
			   dataType: "json",
			   success: function(data){
						recieveTrainingData(data);
			  },
		 });
}


function writeDataToServer(writeString,filename){
	console.log("writeDataToServer");
	 $.ajax({
			   type: "POST",
			   url: "php/writeData.php",
			   data: {
			   			'contents': writeString,
			   			'outputFilename':filename
						},
			   dataType: "json",
			   success: function(data){
						console.log("Written");
			  },
		 });
}


function updatelog(){

	var statx = "completed";
	if(! participantReportsSoundIsFinePostTest){
		statx = "aborted";
	}


	$.ajax({
				type: "POST",
				url: "php/setStatus.php",
				data: {
						 'status': statx,
						 'timestamp':outputFileName
					 },
				dataType: "json",
				success: function(data){
					 console.log("Updated log");
			 },
		});
}

function cancelExperiment(){
	$.ajax({
				type: "POST",
				url: "php/setStatus.php",
				data: {
						 'status': 'aborted',
						 'timestamp':outputFileName
					 },
				dataType: "json",
				success: function(data){
					 console.log("Updated log (cancel)");
			 },
		});
}

function checkIP(){
	$.ajax({
				type: "POST",
				url: "php/checkIP.php",
				data: {
						 'contents': "checkip",
					 },
				dataType: "json",
				success: function(data){
					ipAddressHasDoneThisExperBefore(data.doneBefore);
			 },
		});
}
