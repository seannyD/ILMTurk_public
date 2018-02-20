var startMessage = "\
Thank you for joining our study! By participating in our experiment, you will help us understand how people communicate with each other and how language changes over time.\
<br /><br />\
All of our data will be recorded anonymously.  This work is in line with the ethical guidelines of the University of California, Merced, #UCM07-119. Please contact Bodo Winter (bodo@bodowinter.com) if you have any concerns or questions.\
<br /><br />\
By pressing the arrow button below, you agree to participate in this study.\
";

var serverBusyMessage = "We're sorry - the server is currently busy.  Please try again in an hour.";

var denyParticipantIfIPAddressAlreadyLogged_MESSAGE = "A participant has already done this experiment on this computer";



var reproductionTrainingRound_MESSAGE = "Let's first practice! Listen to the following songs. Can you reproduce them using the bleeper on the right? <br /><br /> Focus on the speed of pitch change!";

var listen_MESSAGE = "Listen!";

var preTrainingRound_MESSAGE = "Now, you’ll see three fish. Each fish sings a special song. Try to remember which song and which fish go together!";

var learningPhase_test_MESSAGE = "Which fish sang this song? Click on the correct one.";

var failedLearningPhase_MESSAGE = "You're doing great! You need to get " + passLearningPhase_NumberOfRoundsBack + " in a row correct to continue.  <br /><br />Get ready for another round of learning!";

var finishedLearningPhase_MESSAGE = "Good job! You remembered all the fish! Keep them in mind for your next task!";

var preReproductionPhase_MESSAGE = "For your next task, you’ll see the fish you just learned, but now you have to reproduce the correct song using the bleeper on the right. \
You can practice your songs now if you want. If you are finished practicing, press the arrow to begin your task!\
";

var finalReproductionPhase_MESSAGE = "Reproduce the song for this fish!  Try to reproduce the song to the best of your ability. Once you feel that you managed to accurately reproduce the sound, continue to the next example.";

var endExperiment_MESSAGE = 'The Experiment is over.\
<br /><br />\
Thank you for participating in our study! \
<br /><br /> Please follow the link below to get your completion code. We will confirm your task completion a soon as possible!\
<br /><br />\
<a target="_blank" href="http://bodowinter.com/TurkGate/codes/generate.php?stamp=10507925&responseID=${e://Field/ResponseID}">Follow this link to get your completion code</a>\
';

var endExperiment_MESSAGE_TABLET = 'The Experiment is over.\
<br /><br />\
Thank you for participating in our study! \
';

var signalTooShort_MESSAGE = "Your song was too short, please try again!";
var signalTooLong_MESSAGE = "Your song was too long, please try again!";

var reproduceTheSignal_MESSAGE = "Reproduce the song you heard using the beeper on the right."


var reproduction_ContinueOrRetry_MESSAGE =  "Try to reproduce the song to the best of your ability. Once you feel that you managed to accurately reproduce the song, continue to the next practice example. <br /><br />Press 'Retry' to try again, or click the arrow to continue.";

var audioNotWorking_MESSAGE = "Sorry, there's a problem with your browser and you cannot complete this task right now.";
