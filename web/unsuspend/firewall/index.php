<?php
use function davidcp\quoteshellarg\quoteshellarg;

// Init
ob_start();
include $_SERVER["DOCUMENT_ROOT"] . "/inc/main.php";

// Check token
verify_csrf($_GET);

// Check user
if ($_SESSION["userContext"] != "admin") {
	header("Location: /list/user");
	exit();
}

if (!empty($_GET["rule"])) {
	$v_rule = quoteshellarg($_GET["rule"]);
	exec(DAVID_CMD . "v-unsuspend-firewall-rule " . $v_rule, $output, $return_var);
}
check_return_code($return_var, $output);
unset($output);

$back = getenv("HTTP_REFERER");
if (!empty($back)) {
	header("Location: " . $back);
	exit();
}

header("Location: /list/firewall/");
exit();
