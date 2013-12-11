<?php
	$destination = "vk@eriv.ru";
	$message = $_REQUEST['message'];
	$email = $_REQUEST['email'];
	$name = $_REQUEST['name'];
	$topic = "eriver feedback form from: ".$name;	
	$headers = "From: ".$email;
	$redirect_to = $_REQUEST['location'];

	mail($destination, $topic, $message, $headers);
	if (isset($redirect_to)) {
		header( "Location: ".$redirect_to );	
	}
	else {
		header( "Location: http://www.eriv.ru" );	
	}
?>