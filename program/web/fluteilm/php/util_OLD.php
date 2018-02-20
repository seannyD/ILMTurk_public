<?php

$logDir = '../../../private/fluteilm/log/';
$logName = "experimentStatus.csv";

$nGenerations = 5;
$nChains = 1;
$nCurvatures = 4;
$minCurvature = 0.1;
$maxCurvature = 0.4;

//$nGenerations = 12;
//$nChains = 10;
//$nCurvatures = 5;
//$maxCurvature = 0.5;

function readCsv($fileDir, $csvName, $lock=true) {
	if($lock) {
		$lockPath = $fileDir . "lock";
		
		clearstatcache();
		while(!@mkdir($lockPath)) {
		 	usleep(rand(50000,200000));
		}
	}
	
	$csvFile = fopen($fileDir . $csvName, "r");
	
	$array = array();
	while(!feof($csvFile)) {
		array_push($array, fgetcsv($csvFile));
	}
	
	array_pop($array);
	fclose($csvFile);
	
	return $array;
}

function unlock($path) {
	if(file_exists($path)) {
		rmdir($path);
	}	
}

function writeLog($array, $fileDir, $fileName) {	
	$newContent = "";

	foreach($array as $row) {
		$newContent .= implode(",", $row) . "\n";
	}

	file_put_contents($fileDir . $fileName, $newContent);
	unlock($fileDir . "lock");
}

function checkDuplicate($langFolder, $fileName) {		
	$truncName = substr($fileName, 0, count($fileName)-5);
	$similars = glob($langFolder . $truncName . "*");
				
	if(count($similars) > 1) {
		if(count($similars)==1) {
			$newName = $truncName . "(1).txt";
		}
		else {
			$values = array();			
			
			foreach($similars as $index => $similar) {
				if($similar != $langFolder . $fileName) {
					$iStart = strpos($similar, "(");
					$iEnd = strpos($similar, ")");
					$value = substr($similar, $iStart+1, $iEnd-($iStart+1));
					$values[$index] = $value;
				}
			}
			
			$indexMax = array_keys($values, max($values));
			$valueMax = $values[$indexMax[0]];
			$nameMax = $similars[$indexMax[0]];
			
			$newName = str_replace("(".$valueMax.")", "(".($valueMax+1).")", $nameMax);				
		}
		return substr($newName, strlen($langFolder));
	}
	else {
		return $fileName;
	}
}

function getTrialValues($trial, $specifier=array()) {
	$values = array();
	
	if(!$specifier || in_array("generation", $specifier)) {	
		array_push($values, substr($trial[1], 11));
	}
	if(!$specifier || in_array("chain", $specifier)) {		
		array_push($values, substr($trial[0], 6));
	}
	if(!$specifier || in_array("curvature", $specifier)) {		
		array_push($values, substr($trial[2], 10));
	}
	if(!$specifier || in_array("path", $specifier)) {		
		array_push($values, $trial[4]);
	}	
	
	return $values;	
}

function resetParent($removedTrial, $trials) {
	$specs = array("generation", "chain", "curvature");
	list($remGen, $remChain, $remCurve) = getTrialValues($removedTrial, $specs);
	
	foreach($trials as &$trial) {
		list($gen, $chain, $curve) = getTrialValues($trial, $specs);
		
		if($remChain === $chain && $remCurve === $curve && $remGen == $gen+1) {
			$trial[5] = "ready";
		}	
	}
	
	return $trials;
}

?>