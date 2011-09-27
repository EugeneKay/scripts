<?php
# ssha512.php
?>
<!--
# Generate a SSHA512(Salted SHA-2 512bit) hash from a given input text. 
#
# Copyright 2011 Eugene E. "EugeneKay" Kashpureff (eugene@kashpureff.org)
# Licensed under GNU General Public License, version 3 or later.
#
-->
<html>
<head>
<title>Salted SHA-512 Generator</title>
</head>
<body>
<center><h1>Salted SHA-512 Generator</h1></center>
<br>
<br>
<center>Source code available on <a href="https://github.com/EugeneKay/scripts/blob/master/php/ssha512.php">GitHub</a></center>
<br>
<br>
<form action="ssha512.php" method="POST">
<center><input type="password" name="password" size="40" value=""><br>
<input type="submit" value="Hash!"></center>
</form>

<?php
if (isset($_POST['password'])) {
	echo "<center><font size=\"-2\">\n";
	$salt = '';
	for ($i=0; $i<=8; $i++ ) {
		$salt .= pack('N', mt_rand());
	}
	$hash = '{SSHA512}' . base64_encode(hash('sha512', $_POST['password'] . $salt, TRUE) . $salt);
	echo $hash."\n";
	echo "</font></center>";
}
?>

</body>
</html>