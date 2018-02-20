<?php

if (!isset($_SERVER["HTTP_HOST"])) {
  parse_str($argv[1], $_POST);
}

include 'util.php';

function updateLog($fileName, $status) {
	global $logDir;
	//global $logName;
	$logName = findCsvFile($fileName);
	echo("FX");
	echo($logDir);
	echo('---');
	echo($logName);
	echo('<<');
	$logArray = readCsv($logDir, $logName);

	$updatedArray = array();
	foreach($logArray as $trial) {
		if($trial[4] == $fileName) {
			if($status == "completed") {
				$trial[5] = "ready";
			}
			elseif($status == "aborted") {
				$trial[5] = "aborted";
			}
			array_push($updatedArray, $trial);
		}
		else{
			array_push($updatedArray, $trial);
		}
	}

	writeLog($updatedArray, $logDir, $logName);
}

$fileName = $_POST['timestamp'];
$status = $_POST['status'];
//$fileName = "output_1_1_04022016185926.txt";
//$status = "aborted";
//$status = "completed";
echo("XXXXX");
if($fileName==""){
	$fileName = $_GET['timestamp'];
	$status = $_GET['status'];
}
updateLog($fileName, $status);

?>
