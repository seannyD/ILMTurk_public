<?php
include 'util.php';
//$reproduceTrainingFile = "../../../private/fluteilm/trainingData/trainingSignals.txt";
global $baseExperDir;
$reproduceTrainingFile = $baseExperDir."trainingData/trainingSignals.txt";
$data['contents'] = "";

if(file_exists($reproduceTrainingFile)){
	$data['contents'] = file_get_contents($reproduceTrainingFile);
}
echo json_encode($data);
