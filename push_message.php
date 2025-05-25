<?php error_reporting(0); ?>
<?php
$callback = $_REQUEST['callback'];
 $file = 'softcenter/push_message.json.js';
$data = file_get_contents($file);
 
//start output
if ($callback) {
    header('Content-Type: application/javascript; charset=utf-8');
    echo $callback . '(' . $data . ');';
} else {
    header('Content-Type: application/x-json');
    echo $data;
}
?>
