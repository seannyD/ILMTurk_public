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

	$resultPath = "output_" . $currentTime->format('dmYHis') . ".txt";

	$newChain = array("chain " . $chain, "generation " . $generation,
		"curvature " . $curvature, $currentTime->format('d-m-Y-H:i:s'),
		$resultPath, "in progress", null);

	return $newChain;
}

function getParameters($trials, $logDir, $logName, $parentName="test.txt") {
	//$langFolder = '../../../private/fluteilm/outputLanguages/';
	global $baseExperDir;
	$langFolder = $baseExperDir.'outputLanguages/';
	$currentTrial = $trials[count($trials) - 1];

	//$currentTrial[4] = "test.txt"; // TODO remove
	//$parentName = "test.txt"; // TODO remove

	$outputFileName = checkDuplicate($langFolder, $currentTrial[4]);
//	echo("----\n");
//	echo($outputFileName.'\n');
//	echo($parentName.'\n');
//	echo("======\n");
//	$csvfilex = findCsvFile($parentName);
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
		return attemptNewCurvature($trials);
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

function attemptNewCurvature($trials) {
	$newTrial = createNewCurvature($trials);

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
	return createNewEntity($trials, $oldGen+1, $nGenerations,
			"createNewCurvature", array("newGen"=>null, "newChain"=>$oldChain,
			"newCurve"=>$oldCurv), $oldPath);
}

function createNewCurvature($trials) {
	global $nCurvatures;
	global $minCurvature;
	global $maxCurvature;
	
	// Sean added the first part of this if statement to handle cases where there's only 1 curvature.
	if($nCurvatures == 1){
		$curvature = $minCurvature;
		$exists = false;

			foreach($trials as $trial) {
				list($trialCurve) = getTrialValues($trial, array("curvature"));

				if(!bccomp($curvature, $trialCurve, 1)) {
					$exists = true;
					break;
				}
			}

			if(!$exists) {
				return createNewEntity($trials, $curvature, $maxCurvature,
						function() {return false;},
						array("newCurve"=>null));
			}
	}
	else {

		$increment = ($maxCurvature-$minCurvature)  / ($nCurvatures-1);

		for($curvature = 0; $curvature <= $maxCurvature; $curvature+=$increment) {
			$exists = false;

			foreach($trials as $trial) {
				list($trialCurve) = getTrialValues($trial, array("curvature"));

				if(!bccomp($curvature, $trialCurve, 1)) {
					$exists = true;
					break;
				}
			}

			if(!$exists) {
				return createNewEntity($trials, $curvature, $maxCurvature,
						function() {return false;},
						array("newCurve"=>null));
			}
		}
	}
}

function createNewEntity($trials, $newValue, $maxValue,
		$followupFunc, $newValues, $parentPath="test.txt") {

	if($newValue <= $maxValue) {

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
	global $nChains;

	for($chain = 1; $chain <= $nChains; $chain++) {
		$logName = "log" . $chain . ".csv";
		$logPath = $logDir . $logName;

		if(!file_exists($logPath)) {
			touch($logPath);
		}

		$logArray = readCsv($logDir, $logName);
		$logArray = changeChain($logArray, -$chain+1);
		$cleanedTrials = cleanLog($logArray);

		if(!$cleanedTrials) {
			global $minCurvature;
			$newTrial = getTrial($chain, 1, $minCurvature);
			array_push($cleanedTrials, $newTrial);
			writeLog($cleanedTrials, $logDir, $logName);
			return getParameters($cleanedTrials, $logDir, $logName);
		}
		else {
			$newTrials = createNewTrial($cleanedTrials);

			if($newTrials) {
				$parentName = array_pop($newTrials[count($newTrials)-1]);
				$newTrials = changeChain($newTrials, $chain-1);
				writeLog($newTrials, $logDir, $logName);
				return getParameters($newTrials, $logDir, $logName, $parentName);
			}
			else {
				if($chain === $nChains) {
					unlock($logDir . "lock");
					$cleanedTrials = changeChain($cleanedTrials, $chain-1);
					writeLog($cleanedTrials, $logDir, $logName);
					return array('busy' => true);
				}
				else {
					writeLog($cleanedTrials, $logDir, $logName);
				}
			}
		}
	}
}

function changeChain($trials, $value) {
	$newTrials = array();

	foreach($trials as $trial) {
		list($chain) = getTrialValues($trial, array("chain"));
		$trial[0] = "chain " . ($chain + $value);
		array_push($newTrials, $trial);
	}

	return $newTrials;
}

$parameters = findTrial();
echo json_encode($parameters);

?>
