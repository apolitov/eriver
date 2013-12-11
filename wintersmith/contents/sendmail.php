<?php
	$destination = "vk@eriv.ru";
	$topic = "eriver feedback form";
	$message = $_REQUEST['message'];
	$email = $_REQUEST['email'];
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