<?php
header("Content-type: text/plain");
#include('kernel.php');
#if (isset($_REQUEST['debug'])){$debug=intval($_REQUEST['debug']);} else {$debug=0;}
if (isset($_REQUEST['note1'])){
  $note1=trim($_REQUEST['note1']);
} else {
  $note1="";
}
if (isset($_REQUEST['note2'])){
  $note2=trim($_REQUEST['note2']);
} else {
  $note2="";
}
if (isset($_REQUEST['action'])){
  $action=trim($_REQUEST['action']);
} else {
  $action="";
}
$appresult = array();

if (isset($_REQUEST['DeviceID'])){$DeviceID=trim($_REQUEST['DeviceID']);} else {$DeviceID="";}
if (isset($_REQUEST['SimSerialNumber'])){$SimSerialNumber=trim($_REQUEST['SimSerialNumber']);} else {$SimSerialNumber="";}
if (isset($_REQUEST['SubscriberID'])){$SubscriberID=trim($_REQUEST['SubscriberID']);} else {$SubscriberID="";}

$file_handle = fopen('./multipartpost.log', 'a+');
fwrite($file_handle, "======================================"."\r\n");
foreach($_REQUEST as $name => $value){
	fwrite($file_handle, date("d.m.Y H:i:s", time()).": ".$name."=".$value."\r\n");
}
fwrite($file_handle, "======================================"."\r\n");

function GetWebname($name){
	$name=str_replace("Ä", "Ae", $name);
	$name=str_replace("Ö", "Oe", $name);
	$name=str_replace("Ü", "Ue", $name);
	$name=str_replace("ä", "ae", $name);
	$name=str_replace("ö", "oe", $name);
	$name=str_replace("ü", "ue", $name);
	$name=str_replace("ß", "ss", $name);
	$name=str_replace(" ", "_", $name);
	$name=str_replace("'", "", $name);
	$name=str_replace("´", "", $name);
	$name=str_replace("&", "and", $name);
	$name=str_replace("/", "", $name);
	$name=str_replace("\\", "", $name);
	$name=str_replace("`", "", $name);
	return strtolower($name);
}
function rand_string($lng=8) {
	mt_srand((double)microtime()*1000000);
	$charset = "123456789ABCDEFGHIJKLMNPQRSTUVWXYZ";
	$length  = strlen($charset)-1;
	$code    = '';
	for($i=0;$i < $lng;$i++) {
	  $code .= $charset{mt_rand(0, $length)};
	}
	return $code;
}

#echo "Akt ST: ".$akt_spieltag."<br />";
#if (isset($_REQUEST['spieltag'])){$spieltag=intval($_REQUEST['spieltag']);} else {$spieltag=$akt_spieltag;}

if($action==""){
	$action = "overview";
}



if ($action == "overview"){
  #
}elseif($action == "upload"){
  $uploads[] = array(); 
  fwrite($file_handle, "======= FILES ========================"."\r\n");
  foreach($_FILES as $name => $value){
    $uploads[$name] = $value;
    foreach($value as $fname => $fvalue){
    	fwrite($file_handle, date("d.m.Y H:i:s", time()).": ".$fname."=".$fvalue."\r\n");
    }
  	fwrite($file_handle, date("d.m.Y H:i:s", time()).": Upload of \"".$name."\"\r\n");
    if($name=="Aufnahme"){
      $uploaddir = './uploads/';
      $uploadfile = $uploaddir . basename($_FILES[$name]['name']);
     	fwrite($file_handle, date("d.m.Y H:i:s", time()).": MoveUploadedFile(".$_FILES[$name]['name'].")\r\n");
      if (move_uploaded_file($_FILES[$name]['tmp_name'], $uploadfile)) {
        $uploads[$name]["status"] = $_FILES[$name]['name']." saved successfull";
      	fwrite($file_handle, date("d.m.Y H:i:s", time()).": ->moving ".$_FILES[$name]['name']." successfull\r\n");
          #echo "Datei ist valide und wurde erfolgreich hochgeladen.\n";
      } else {
        $uploads[$name]["status"] = $_FILES[$name]['name']." failed to save!";
      	fwrite($file_handle, date("d.m.Y H:i:s", time()).":->moving ".$_FILES[$name]['name']." NOT successfull\r\n");
          #echo "Möglicherweise eine Dateiupload-Attacke!\n";
      }
    } 
    if($name=="coca_cola"){
      $uploaddir = './uploads/';
      $uploadfile = $uploaddir . basename($_FILES[$name]['name']);
  
     	fwrite($file_handle, date("d.m.Y H:i:s", time()).": MoveUploadedFile(".$_FILES[$name]['name'].")\r\n");
      if (move_uploaded_file($_FILES[$name]['tmp_name'], $uploadfile)) {
        $uploads[$name]["status"] = $_FILES[$name]['name']." saved successfull";
      	fwrite($file_handle, date("d.m.Y H:i:s", time()).": ->moving ".$_FILES[$name]['name']." successfull\r\n");
      } else {
        $uploads[$name]["status"] = $_FILES[$name]['name']." failed to save!";
      	fwrite($file_handle, date("d.m.Y H:i:s", time()).":->moving ".$_FILES[$name]['name']." NOT successfull\r\n");
      }
    } 
    foreach($value as $fname => $fvalue){
    	fwrite($file_handle, date("d.m.Y H:i:s", time()).": ".$fname."=".$fvalue."\r\n");
    }
  }
  fwrite($file_handle, "======================================"."\r\n");
	#print_r($uploads);
  $appresult["uploads"] = $uploads; 
  
  echo json_encode($appresult);
  #
}else{
}
fclose($file_handle);
?>