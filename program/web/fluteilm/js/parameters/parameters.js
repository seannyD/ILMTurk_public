var shuffleMappingBetweenSignalsAndMeanings = true;
var maxSignalLength_milliseconds = 5000;
var minSignalLength_milliseconds = 150;

var sliderRemainsUntilNextButtonInIntroduction = true;

var canListenAgainInIntroduction = true;

var denyParticipantIfIPAddressAlreadyLogged = false;

var showNodeInSliderDuringInitialTraining = true;

var firstGenerationSignalsAreInLinearPhysicalSpace = true;

var askParticipantsForAgeGenderLang = true;

var numMeanings = 3;  // if 4, need to set guess panel option parameters in css

var meanings = ['images/meanings/1.png','images/meanings/2.png','images/meanings/3.png','images/meanings/4.png'];


// conditions for ending learning
// e.g. if participants must get 100% correct for all stimuli, two rounds in a row,
// numberOfRoundsBack = 2 *4;
// ProportionCorrectResponses = 1;
var passLearningPhase_NumberOfRoundsBack = numMeanings*2;
var passLearningPhase_ProportionCorrectResponses = 1;

var maximumNumberOfLearningPhases = 12;

// if it's a test experiment, should the log be cancelled
var cancelExperimentImmedatelyInTestMode = true;
