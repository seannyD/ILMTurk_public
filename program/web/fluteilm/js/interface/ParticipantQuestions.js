var participantGender = "";
var participantAge = "";
var participantNativeLanguage = "";
var participantSONAID = "";


pDetailsForm = '\
Please indicate your sex:\
<br />\
<select id="P_gender" onchange="changeGender()">\
  <option value="blank"></option>\
   <option value="f">Female</option>\
   <option value="m">Male</option>\
   <option value="n">Prefer not to say</option>\
</select>\
<br /><br />\
Please enter your age (leave blank if you prefer not to say):\
<br />\
<input id="P_age" onkeyup="changeAge()">\
<br /><br />\
What is your native language or languages? (leave blank if you prefer not to say)\
<br />\
<input id="P_lang" onkeyup="changeLang()">\
';

pDetailsForm_SONA = '\
Please enter your SONA id:\
<br />\
<input id="P_SONA" onkeyup="changeSONA()"">\
<br />\
Please indicate your sex:\
<br />\
<select id="P_gender" onchange="changeGender()">\
  <option value="blank"></option>\
   <option value="f">Female</option>\
   <option value="m">Male</option>\
   <option value="n">Prefer not to say</option>\
</select>\
<br /><br />\
Please enter your age (leave blank if you prefer not to say):\
<br />\
<input id="P_age" onkeyup="changeAge()">\
<br /><br />\
What is your native language or languages? (leave blank if you prefer not to say)\
<br />\
<input id="P_lang" onkeyup="changeLang()">\
';

function changeGender(){
  participantGender = document.getElementById("P_gender").value;
}

function changeAge(){
  participantAge = document.getElementById("P_age").value;
}

function changeLang(){
  participantNativeLanguage = document.getElementById("P_lang").value;
}

function changeSONA(){
  participantSONAID =  document.getElementById("P_SONA").value;
}
