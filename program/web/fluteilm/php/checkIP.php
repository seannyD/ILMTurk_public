<?php
include 'util.php';

function get_client_ip() {
    $ipaddress = '';
    if ($_SERVER['HTTP_CLIENT_IP'])
        $ipaddress = $_SERVER['HTTP_CLIENT_IP'];
    else if($_SERVER['HTTP_X_FORWARDED_FOR'])
        $ipaddress = $_SERVER['HTTP_X_FORWARDED_FOR'];
    else if($_SERVER['HTTP_X_FORWARDED'])
        $ipaddress = $_SERVER['HTTP_X_FORWARDED'];
    else if($_SERVER['HTTP_FORWARDED_FOR'])
        $ipaddress = $_SERVER['HTTP_FORWARDED_FOR'];
    else if($_SERVER['HTTP_FORWARDED'])
        $ipaddress = $_SERVER['HTTP_FORWARDED'];
    else if($_SERVER['REMOTE_ADDR'])
        $ipaddress = $_SERVER['REMOTE_ADDR'];
    else
        $ipaddress = 'UNKNOWN';
    return $ipaddress;
}


//$ipfolder = "../../../private/fluteilm/ipLog/";
$ipfolder = $baseExperDir."ipLog/";

$ipfile = "ipLog.csv";
$oldIPs = readCsv($ipfolder, $ipfile, false);



$myIP = get_client_ip();

$data['doneBefore'] = false;

if($myIP!="UNKNOWN"){
  foreach($oldIPs as $ip) {
    if($ip[0] == $myIP){
      $data['doneBefore'] = true;
      break;
    }
  }

}
if((!$data['doneBefore']) && ($myIP!="UNKNOWN")){
  array_push($oldIPs, [$myIP]);
  writeLog($oldIPs, $ipfolder, $ipfile);
}

echo json_encode($data);
