String.prototype.replaceAll = function(search, replacement) {
    var target = this;
    return target.replace(new RegExp(search, 'g'), replacement);
};

function viewLog(){
	$.ajax({
				type: "POST",
				url: "php/viewLog.php",
				data: {
						 'request': "999",
					 },
				dataType: "json",
				success: function(data){
          showLog(data.log);
			 },
		});
}

function showLog(t){
	t = t.replaceAll("\n","<br />");
	 document.getElementById("log").innerHTML = t;
}
