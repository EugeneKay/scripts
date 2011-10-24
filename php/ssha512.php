<?php
// ssha512.php

/*
// Generate a SSHA512(Salted SHA-2 512bit) hash from a given input text. 
//
// Copyright 2011 Eugene E. "EugeneKay" Kashpureff (eugene@kashpureff.org)
// License: WTFPL, any version or GNU General Public License, version 3+
*/
?>
<!-- 
Generate a SSHA512(Salted SHA-2 512bit) hash from a given input text. 

Copyright 2011 Eugene E. "EugeneKay" Kashpureff (eugene@kashpureff.org)
License: WTFPL, any version or GNU General Public License, version 3+
-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<meta http-equiv="Content-type" content="text/html;charset=UTF-8" /> 
<title>Salted SHA-512 Generator</title>
<style type="text/css">
a:link,
a:visited {
	text-decoration: none;
	color: #00f;
}
a:hover,
a:active {
	text-decoration: none;
	color: #f00;
}
fieldset {
	margin: 0;
	border: 0;
	padding: 0;
}
#header {
	text-align: center;
	font-size: 4em;
}
#passform {
	text-align: center;
	margin: 2em;
}
#passhash {
	text-align: center;
	margin: 2em;
	font-size: 0.5em;
}
#footer {
	position: fixed;
	bottom: 0px;
	width: 99%;
}
#footer div {
	width: 500px;
	position: static;
	
	margin: 0 auto 0 auto;
	border-style: solid;
	border-width: 1px 1px 0 1px;
	border-color: #000;
	padding: 5px;
	text-align: center;
	font-size: 1.5em;
}
</style>			
</head>
<body>
<div id="header">SSHA512 Generator</div>
<p id="passform">
<object>
<form action="ssha512.php" method="post">
<fieldset>
<input type="password" name="password" size="40" value="" autocomplete="off" />
<input type="submit" value="Hash!" />
</fieldset>
</form>
</object>
</p>

<?php
if (isset($_POST['password'])) {
	echo "<p id=\"passhash\">\n";
	$salt='';
	for ($i=0; $i<=8; $i++ ) {
		$salt.=pack('N', mt_rand());
	}
	$hash='{SSHA512}'.base64_encode(hash('sha512', $_POST['password'].$salt, TRUE).$salt);
	echo $hash."\n";
	echo "</p>\n";
}
?>
<div id="footer">
	<div>Source code available on <a href="https://github.com/EugeneKay/scripts/blob/master/php/ssha512.php">GitHub</a></div>
</div>
</body>
</html>
