<?php

include 'util.php';
date_default_timezone_set('Europe/Amsterdam');

function getParentTrial($trials, $propertyName) {	
	$values = array();
	foreach($trials as $trial) {
		list($value) = getTrialValues($trial, array($propertyName));
		array_push($values, $value);
	}
	
	$valueMax = max($values);
	$indexValueMax = array_search($valueMax, $values);
	$parentTrial = $trials[$indexValueMax];
	
	return $parentTrial;	
}

function getTrial($chain, $generation, $curvature) {
	$currentTime = new DateTime('now');

	$resultPath = "output_" . $chain . "_" . $generation . "_" .
		$currentTime->format('dmYHis') . ".txt";

	$newChain = array("chain " . $chain, "generation " . $generation,
		"curvature " . $curvature, $currentTime->format('d-m-Y-H:i:s'),
		$resultPath, "in progress", null);

	return $newChain;
}

function getParameters($trials, $logDir, $logName, $parentName="test.txt") {	
	$langFolder = '../../../private/fluteilm/outputLanguages/';
	$currentTrial = $trials[count($trials) - 1];
	
	//$currentTrial[4] = "test.txt"; // TODO remove
	//$parentName = "test.txt"; // TODO remove
	
	$outputFileName = checkDuplicate($langFolder, $currentTrial[4]);
	$fcont = readCsv($langFolder, $parentName, false);
			
	$parameters = array('busy'=>false,
						'chainNum'=>substr($currentTrial[0],6),
						'genNum'=>substr($currentTrial[1],11),
						'curvature'=>substr($currentTrial[2],10),
						'parentPath'=>$parentName,
						'outputFileName'=>$outputFileName,
						'signals'=>$fcont);
	
	return $parameters;
}

function sortTrials($trials) {	
	foreach($trials as &$trial) {
		$specs = array("generation", "chain", "curvature");
		list($generation, $chain, $curve) = getTrialValues($trial, $specs);
		
		$curveGenerations = 0;	
		foreach($trials as $cmpTrial) {
			$specs = array("generation", "chain", "curvature");
			list($cmpGen, $cmpChain, $cmpCurve) = getTrialValues($cmpTrial, $specs);
			
			if($curve === $cmpCurve) {
				$curveGenerations += $cmpGen;
			}
		}
		array_push($trial, $generation, $curveGenerations);
	}
	
	$genIndex = count($trials[0]) - 2;
	$curveIndex = count($trials[0]) - 1;
	
	usort($trials, function($trialA, $trialB) use ($genIndex, $curveIndex) {		
		if($trialA[$curveIndex] === $trialB[$curveIndex]) {
			return $trialA[$genIndex] < $trialB[$genIndex];
		}
		else {
			return $trialA[$curveIndex] < $trialB[$curveIndex];
		}
	});
	
	return $trials;
}

function createNewTrial($trials) {
	$readyTrials = array();
	foreach($trials as $index => $trial) {		
		if($trial[5] === "ready") {
			array_push($trial, $index);
			array_push($readyTrials, $trial);			
		}
	}
	
	if($readyTrials) {
		return attemptNewGeneration($trials, $readyTrials);	
	}
	else {
		return attemptNewChain($trials);
	}
}

function attemptNewGeneration($trials, $readyTrials) {
	$sortedTrials = sortTrials($readyTrials);	
		
	foreach($sortedTrials as &$trial) {
		$newTrial = createNewGeneration($trial, $trials);
		
		if(!$newTrial) {
			return $newTrial;
		}
		else {
			$oldTrialIndex = $trial[7];
			$trials[$oldTrialIndex][5] = "completed";
			
			array_push($trials, $newTrial);
			
			return $trials;	
		}
	}
}

function attemptNewChain($trials) {
	$curvatures = array();	
	foreach($trials as $trial) {
		list($curvature) = getTrialValues($trial, array("curvature"));
		array_push($curvatures, $curvature);
	}
	
	$maxCurve = max($curvatures);
	
	$maxCurveTrials = array();
	foreach($trials as $trial) {
		if($trial[2] === "curvature ".$maxCurve) {
			array_push($maxCurveTrials, $trial);
		}
	}
	
	$sortedTrials = sortTrials($maxCurveTrials);
	$newTrial = createNewChain($sortedTrials);	
	
	if(!$newTrial) {
		return $newTrial;
	}
	else {
		array_push($trials, $newTrial);
		return $trials;			
	}
}

function createNewGeneration($oldTrial, $trials) {	
	list($oldGen, $oldChain, $oldCurv, $oldPath) = getTrialValues($oldTrial);
	
	global $nGenerations;
	return createNewEntity($trials, $oldGen, $nGenerations, 
			1, "createNewChain", array("newGen"=>null, "newChain"=>$oldChain, 
			"newCurve"=>$oldCurv), $oldPath);				
}

function createNewChain($trials) {	
	$oldTrial = getParentTrial($trials, "chain");
	$specs = array("chain", "curvature");
	list($oldChain, $oldCurv) = getTrialValues($oldTrial, $specs);
	
	global $nChains;
	return createNewEntity($trials, $oldChain, $nChains, 1, 
			"createNewCurvature", array("newChain"=>null, "newCurve"=>$oldCurv));
}

function createNewCurvature($trials) {
	$oldTrial = getParentTrial($trials, "curvature");
	$specs = array("curvature");
	list($oldCurv) = getTrialValues($oldTrial, $specs);
	
	global $nCurvatures;
	global $minCurvature;
	global $maxCurvature;
	$increment = ($maxCurvature-$minCurvature)  / ($nCurvatures-1);
	
	return createNewEntity($trials, $oldCurv, $maxCurvature, 
			$increment, function() {return false;}, 
			array("newCurve"=>null)); 
}

function createNewEntity($trials, $oldValue, $maxValue, $valueIncrement, 
		$followupFunc, $newValues, $parentPath="test.txt") {			
				
	if($oldValue < $maxValue) {
		$newValue = $oldValue + $valueIncrement;
		
		$defaultValues = array("newGen"=>1, "newChain"=>1, "newCurve"=>1);				   					   
		$newValues = array_merge($defaultValues, $newValues);
		
		$keyNullValue = array_search(null, $newValues);
		$newValues[$keyNullValue] = $newValue;	
		
		extract($newValues);
		
		$newTrial = getTrial($newChain, $newGen, $newCurve);
		
		array_push($newTrial, $parentPath);
		
		return $newTrial;		
	}
	else {
		return call_user_func($followupFunc, $trials);
	}
}

function cleanLog($logArray) {
	global $nGenerations;	
	
	$freedArray = array();
	foreach($logArray as $trial) {
		if($trial[5] === "ready" && $trial[1] === "generation ".$nGenerations) {
			$trial[5] = "completed";
			array_push($freedArray, $trial);
		}		
		else {
			if($trial[5] === "aborted") {
				$freedArray = resetParent($trial, $freedArray);
			}
			elseif($trial[5] === "in progress") {
				$dateTimeTrial = DateTime::createFromFormat("d-m-Y-H:i:s", $trial[3]);
				$stringTrial = $dateTimeTrial->format("Y-m-d H:i:s");
				$timeTrial = strtotime($stringTrial);
	
				if($timeTrial > strtotime("20 minutes ago")) {
					array_push($freedArray, $trial);
				}
				else {
					$freedArray = resetParent($trial, $freedArray);
				}
			}
			else {
				array_push($freedArray, $trial);
			}
		}
	}
	
	return $freedArray;
}

function findTrial(){
	global $logDir;
	global $logName;
	$logArray = readCsv($logDir, $logName);
	$cleanedTrials = cleanLog($logArray);
	
	if(!$cleanedTrials) {
		global $minCurvature;
		$newTrial = getTrial(1, 1, $minCurvature);
		array_push($cleanedTrials, $newTrial);
		writeLog($cleanedTrials, $logDir, $logName);
		return getParameters($cleanedTrials, $logDir, $logName);
	}
	else {
		$newTrials = createNewTrial($cleanedTrials);
		
		if(!$newTrials) {
			unlock($logDir . "lock");
			writeLog($cleanedTrials, $logDir, $logName);				
			return array('busy' => true);		
		}
		else {
			$parentName = array_pop($newTrials[count($newTrials)-1]);
			writeLog($newTrials, $logDir, $logName);			
			return getParameters($newTrials, $logDir, $logName, $parentName);
		}
	}
}

$parameters = findTrial();
echo json_encode($parameters);

?>