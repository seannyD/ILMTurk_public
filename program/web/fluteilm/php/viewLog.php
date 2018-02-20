<?php
include 'util.php';
//$logFile = "../../../private/fluteilm/log/experimentStatus.csv";
$logFile = $baseExperDir."log/experimentStatus.csv";
$data['log'] = "";
if(file_exists($logFile)){
	$data['log'] = file_get_contents($logFile);
}
echo json_encode($data);
