<?php
include 'util.php';

//$writeToFolder = '../../../private/fluteilm/';
$writeToFolder = $baseExperDir;

$fileName = $_POST['outputFilename'];
$contents = $_POST['contents'];

$log = array();
if(strpos($fileName, '../') === FALSE){
	if((fwrite(fopen($writeToFolder . $fileName,'w'),$contents))){
		$log['state'] = "WRITTEN";
	}
	else{
		$log['state'] = "Not written";
	}
}

echo json_encode($log);
