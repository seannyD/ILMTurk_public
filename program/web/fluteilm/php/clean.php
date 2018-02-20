<?php

include 'util.php';

function checkValues($values, $toRemoves, $counter=0) {
	if(count($values)===0) {
		return false;
	}
	else {
		$value = array_pop($values);
		$toRemove = array_pop($toRemoves);
		
		if($counter===2 ? $value>=$toRemove : $value==$toRemove) {
			return checkValues($values, $toRemoves, $counter+1);
		}
		else {
			return true;
		}
	}
}

function cleanCommon($toRemoves, $specs) {
	global $logDir;
	global $logName;
	
	$trials = readCsv($logDir, $logName, false);
	
	$filteredTrials = array();
	foreach($trials as $trial) {
		$values = getTrialValues($trial, $specs);
		
		$keep = checkValues($values, array_reverse($toRemoves));
		if($keep) {
			array_push($filteredTrials, $trial);
		}
		else {
			$filteredTrials = resetParent($trial, $filteredTrials);
		}
	}
	
	writeLog($filteredTrials, $logDir, $logName);
}

function clean() {
	$nArguments = func_num_args();
	
	switch($nArguments) {
		case 1:
			$specs=array("curvature");
			cleanCommon(func_get_args(), $specs);
			break;
		case 2:
			$specs=array("chain", "curvature");
			cleanCommon(func_get_args(), $specs);
			break;
		case 3:
			$specs=array("generation", "chain", "curvature");
			cleanCommon(func_get_args(), $specs);
			break;						
	}
}

clean(0.1, 1, 2);

?>