<?php

use function davidcp\quoteshellarg\quoteshellarg;
$TAB = "SERVER";

// Main include
include $_SERVER["DOCUMENT_ROOT"] . "/inc/main.php";

// Check user
if ($_SESSION["userContext"] !== "admin" && $user_plain === "$ROOT_USER") {
	header("Location: /list/user");
	exit();
}

// Check POST request
if (!empty($_POST["save"])) {
	if (!empty($_POST["v_config"])) {
		$fp = tmpfile();
		$new_conf = stream_get_meta_data($fp)["uri"];
		$config = str_replace("\r\n", "\n", $_POST["v_config"]);
		if (!str_ends_with($config, "\n")) {
			$config .= "\n";
		}
		fwrite($fp, $config);
		exec(
			HESTIA_CMD .
				"v-change-sys-service-config " .
				quoteshellarg($new_conf) .
				" davidweb yes",
			$output,
			$return_var,
		);
		check_return_code($return_var, $output);
		unset($output);
		fclose($fp);
	}
}

$v_config_path = "/var/spool/cron/crontabs/davidweb";
$v_service_name = _("Panel Cronjobs");

// Read config
$v_config = shell_exec(HESTIA_CMD . "v-open-fs-config " . $v_config_path);

// Render page
render_page($user, $TAB, "edit_server_service");

// Flush session messages
unset($_SESSION["error_msg"]);
unset($_SESSION["ok_msg"]);
