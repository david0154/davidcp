#!/usr/bin/env php
<?php
#
# Auto create multiple Hesia containers with various features enabled/disabled
# lxc/lxd should be allready configured
#   echo "root:1000:1" | sudo tee -a /etc/subuid
#   echo "root:1000:1" | sudo tee -a /etc/subgid
#
# - container name will be generated depending on enabled features (os,proxy,webserver and php)
# - 'SHARED_HOST_FOLDER' will be mounted in the (guest lxc) container at '/home/ubuntu/source/' and davidcp src folder is expected to be there
# - wildcard dns *.dvp.domain.tld can be used to point to vm host
# - watch install log ex:(host) tail -n 100 -f /tmp/dvp_installer_dvp-ub1604-a2-mphp
#
# CONFIG HOST STEPS:
#   export SHARED_HOST_FOLDER="/home/myuser/projectfiles"
#   mkdir -p $SHARED_HOST_FOLDER
#   cd $SHARED_HOST_FOLDER && git clone https://github.com/davidcp/davidcp.git && cd davidcp && git checkout ..branch..
#

/*
# Nginx reverse proxy config: /etc/nginx/conf.d/lxc-david.conf
server {
    listen 80;
    server_name ~(?<lxcname>dvp-.+)\.dvp\.domain\.tld$;
    location / {
        set $backend_upstream "http://$lxcname:80";
        proxy_pass $backend_upstream;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $remote_addr;
    }
}
server {
    listen 8083;
    server_name ~^(?<lxcname>dvp-.+)\.dvp\.domain\.tld$;
    location / {
        set $backend_upstream "https://$lxcname:8083";
        proxy_pass $backend_upstream;
    }
}

# use lxc resolver /etc/nginx/nginx.conf
# test resolver ip ex: dig +short @10.240.232.1 dvp-ub1804-ngx-a2-mphp
http {
...
    resolver 10.240.232.1 ipv6=off valid=5s;
...
}

*/

##  Uncomment and configure the following vars
# define('DOMAIN',     'dvp.domain.tld');
# define('SHARED_HOST_FOLDER', '/home/myuser/projectfiles');
# define('DVP_PASS',   ''); // <- # openssl rand -base64 12
# define('DVP_EMAIL',  'user@domain.tld');
define("DVP_BRANCH", "~localsrc");
define("DVP_ARGS", "--force --interactive no --clamav no -p " . DVP_PASS . " --email " . DVP_EMAIL);
define("LXC_TIMEOUT", 30);

if (
	!defined("SHARED_HOST_FOLDER") ||
	!defined("DVP_PASS") ||
	!defined("DVP_EMAIL") ||
	!defined("DVP_BRANCH") ||
	!defined("DOMAIN")
) {
	die("Error: missing variables" . PHP_EOL);
}

$containers = [
	//    ['description'=>'dvp-d9-ngx-a2-mphp',       'os'=>'debian9',     'nginx'=>true,  'apache2'=>true,    'php'=>'multiphp',  'dns'=>'auto', 'exim'=>'auto'],
	[
		"description" => "ub1804 ngx mphp",
		"os" => "ubuntu18.04",
		"nginx" => true,
		"apache2" => false,
		"php" => "multiphp",
		"dns" => "auto",
		"exim" => "auto",
	],
	[
		"description" => "ub1804 ngx fpm",
		"os" => "ubuntu18.04",
		"nginx" => true,
		"apache2" => false,
		"php" => "fpm",
		"dns" => "auto",
		"exim" => "auto",
	],
	[
		"description" => "ub1804 ngx a2",
		"os" => "ubuntu18.04",
		"nginx" => true,
		"apache2" => true,
		"php" => "auto",
		"dns" => "auto",
		"exim" => "auto",
	],
	[
		"description" => "ub1804 ngx a2 mphp",
		"os" => "ubuntu18.04",
		"nginx" => true,
		"apache2" => true,
		"php" => "multiphp",
		"dns" => "auto",
		"exim" => "auto",
	],
	[
		"description" => "ub1804 ngx a2 fpm",
		"os" => "ubuntu18.04",
		"nginx" => true,
		"apache2" => true,
		"php" => "fpm",
		"dns" => "auto",
		"exim" => "auto",
	],
	[
		"description" => "ub1804 a2 mphp",
		"os" => "ubuntu18.04",
		"nginx" => false,
		"apache2" => true,
		"php" => "multiphp",
		"dns" => "auto",
		"exim" => "auto",
	],
	[
		"description" => "ub1804 a2 fpm",
		"os" => "ubuntu18.04",
		"nginx" => false,
		"apache2" => true,
		"php" => "fpm",
		"dns" => "auto",
		"exim" => "auto",
	],
	[
		"description" => "ub1804 a2",
		"os" => "ubuntu18.04",
		"nginx" => false,
		"apache2" => true,
		"php" => "auto",
		"dns" => "auto",
	],
	[
		"description" => "ub1604 a2 mphp",
		"os" => "ubuntu16.04",
		"nginx" => false,
		"apache2" => true,
		"php" => "multiphp",
		"dns" => "auto",
		"exim" => "auto",
	],
];

array_walk($containers, function (&$element) {
	$lxc_name = "dvp-"; // hostname and lxc name prefix. Update nginx reverse proxy config after altering this value
	$dvp_args = DVP_ARGS;

	$element["dvp_installer"] = "dvp-install-ubuntu.sh";
	$element["lxc_image"] = "ubuntu:18.04";

	if ($element["os"] == "ubuntu16.04") {
		$element["lxc_image"] = "ubuntu:16.04";
		$lxc_name .= "ub1604";
	} elseif ($element["os"] == "debian8") {
		$element["lxc_image"] = "images:debian/8";
		$element["dvp_installer"] = "dvp-install-debian.sh";
		$lxc_name .= "d8";
	} elseif ($element["os"] == "debian9") {
		$element["lxc_image"] = "images:debian/9";
		$element["dvp_installer"] = "dvp-install-debian.sh";
		$lxc_name .= "d9";
	} else {
		$lxc_name .= "ub1804";
		$element["os"] = "ubuntu18.04";
	}

	if ($element["nginx"] === true) {
		$lxc_name .= "-ngx";
		$dvp_args .= " --nginx yes";
	} else {
		$dvp_args .= " --nginx no";
	}

	if ($element["apache2"] === true) {
		$lxc_name .= "-a2";
		$dvp_args .= " --apache yes";
	} else {
		$dvp_args .= " --apache no";
	}

	if ($element["php"] == "fpm") {
		$lxc_name .= "-fpm";
		$dvp_args .= " --phpfpm yes";
	} elseif ($element["php"] == "multiphp") {
		$lxc_name .= "-mphp";
		$dvp_args .= " --multiphp yes";
	}

	if (isset($element["dns"])) {
		if ($element["dns"] === true || $element["dns"] == "auto") {
			$dvp_args .= " --named yes";
		} else {
			$dvp_args .= " --named no";
		}
	}

	if (isset($element["exim"])) {
		if ($element["exim"] === true || $element["exim"] == "auto") {
			$dvp_args .= " --exim yes";
		} else {
			$dvp_args .= " --exim no";
		}
	}

	if (isset($element["webmail"])) {
		if ($element["webmail"] === true || $element["webmail"] == "auto") {
			$dvp_args .= " --dovecot yes";
		} else {
			$dvp_args .= " --dovecot no";
		}
	}

	$element["lxc_name"] = $lxc_name;
	$element["hostname"] = $lxc_name . "." . DOMAIN;

	// $dvp_args .= ' --with-debs /home/ubuntu/source/davidcp/src/pkgs/develop/' . $element['os'];
	$dvp_args .= " --with-debs /tmp/davidcp-src/debs";
	$dvp_args .= " --hostname " . $element["hostname"];
	$element["dvp_args"] = $dvp_args;
});

function lxc_run($args, &$rc) {
	$cmd_args = "";

	if (is_array($args)) {
		foreach ($args as $arg) {
			$cmd_args .= " " . escapeshellarg($arg);
		}
	} else {
		$cmd_args = $args;
	}

	exec("lxc " . $cmd_args . " 2>/dev/null", $cmdout, $rc);

	if (isset($rc) && $rc !== 0) {
		return false;
	}

	if (json_decode(implode(PHP_EOL, $cmdout), true) === null) {
		return $cmdout;
	}

	return json_decode(implode(PHP_EOL, $cmdout), true);
}

function getHestiaVersion($branch) {
	$control_file = "";
	if ($branch === "~localsrc") {
		$control_file = file_get_contents(SHARED_HOST_FOLDER . "/davidcp/src/deb/david/control");
	} else {
		$control_file = file_get_contents(
			"https://raw.githubusercontent.com/david0154/davidcp/${branch}/src/deb/david/control",
		);
	}

	foreach (explode(PHP_EOL, $control_file) as $line) {
		if (empty($line)) {
			continue;
		}

		[$key, $value] = explode(":", $line);
		if (strtolower($key) === "version") {
			return trim($value);
		}
	}

	throw new Exception("Error reading David version for branch: [${branch}]", 1);
}

function get_lxc_ip($name) {
	$result = lxc_run(["list", "--format", "csv", "-c", "n,4"], $rc);
	if (empty($result)) {
		return false;
	}

	foreach ($result as $line) {
		[$cnt, $address] = explode(",", $line);
		if ($cnt == $name) {
			$iface = explode(" ", $address);
			if (filter_var($iface[0], FILTER_VALIDATE_IP)) {
				return $iface[0];
			} else {
				return false;
			}
		}
	}
}

function check_lxc_container($container) {
	echo "Check container:" . $container["lxc_name"] . PHP_EOL;

	lxc_run(["info", $container["lxc_name"]], $rc);
	if (isset($rc) && $rc === 0) {
		return;
	}

	$pid = pcntl_fork();
	if ($pid > 0) {
		return $pid;
	}

	echo "Creating container " . $container["lxc_name"] . PHP_EOL;
	lxc_run(["init", $container["lxc_image"], $container["lxc_name"]], $rc);
	exec(
		"lxc config set " .
			escapeshellarg($container["lxc_name"]) .
			' raw.idmap "both 1000 1000" 2>/dev/null',
		$devnull,
		$rc,
	);
	exec(
		"lxc config device add " .
			escapeshellarg($container["lxc_name"]) .
			" davidsrc disk path=/home/ubuntu/source source=" .
			SHARED_HOST_FOLDER .
			" 2>/dev/null",
		$devnull,
		$rc,
	);
	lxc_run(["start", $container["lxc_name"]], $rc);

	$lxc_retry = 0;
	do {
		$lxc_retry++;
		$cip = get_lxc_ip($container["lxc_name"]);
		if ($cip) {
			echo "Container " . $container["lxc_name"] . " IP: $cip" . PHP_EOL;
		}
		sleep(1);
	} while ($lxc_retry <= LXC_TIMEOUT && filter_var($cip, FILTER_VALIDATE_IP) === false);

	echo "Updating container: " . $container["lxc_name"] . PHP_EOL;
	exec("lxc exec " . $container["lxc_name"] . " -- apt update", $devnull, $rc);

	exit(0);
}

function dvp_installer_worker($container) {
	$pid = pcntl_fork();
	if ($pid > 0) {
		return $pid;
	}

	system(
		"lxc exec " .
			$container["lxc_name"] .
			' -- bash -c "/home/ubuntu/source/davidcp/src/dvp_autocompile.sh --david \"' .
			DVP_BRANCH .
			'\" no"',
	);

	$hver = getHestiaVersion(DVP_BRANCH);
	echo "Install David ${hver} on " . $container["lxc_name"] . PHP_EOL;
	echo "Args: " . $container["dvp_args"] . PHP_EOL;

	system(
		"lxc exec " .
			$container["lxc_name"] .
			' -- bash -c "cd \"/home/ubuntu/source/davidcp\"; install/' .
			$container["dvp_installer"] .
			" " .
			$container["dvp_args"] .
			'" 2>&1 > /tmp/dvp_installer_' .
			$container["lxc_name"],
	);

	exit(0);
}

// Create and update containers
$worker_pool = [];
foreach ($containers as $container) {
	$worker_pid = check_lxc_container($container);
	if ($worker_pid > 0) {
		$worker_pool[] = $worker_pid;
	}
}

echo count($worker_pool) . " LXC workers started" . PHP_EOL;
# waiting for workers to finish
while (count($worker_pool)) {
	echo "Wait for LXC workers to finish" . PHP_EOL;
	$child_pid = pcntl_wait($status);
	if ($child_pid) {
		$worker_pos = array_search($child_pid, $worker_pool);
		unset($worker_pool[$worker_pos]);
	}
}

// Install David
$worker_pool = [];
foreach ($containers as $container) {
	# Is david installed?
	lxc_run("exec " . $container["lxc_name"] . ' -- sudo --login "v-list-sys-config"', $rc);
	if (isset($rc) && $rc === 0) {
		continue;
	}

	$worker_pid = dvp_installer_worker($container);
	if ($worker_pid > 0) {
		$worker_pool[] = $worker_pid;
	}
}

echo count($worker_pool) . " background workers started" . PHP_EOL;
# waiting for workers to finish
while (count($worker_pool)) {
	echo "Wait for workers to finish" . PHP_EOL;
	$child_pid = pcntl_wait($status);
	if ($child_pid) {
		$worker_pos = array_search($child_pid, $worker_pool);
		unset($worker_pool[$worker_pos]);
	}
}

// Custom config
foreach ($containers as $container) {
	echo "Apply custom config on: " . $container["lxc_name"] . PHP_EOL;

	# Allow running a reverse proxy in front of David
	system(
		"lxc exec " .
			$container["lxc_name"] .
			' -- bash -c "sed -i \'s/session.cookie_secure] = on\$/session.cookie_secure] = off/\' /usr/local/david/php/etc/php-fpm.conf"',
	);

	# get rid off "mesg: ttyname failed: No such device" error
	system(
		"lxc exec " .
			$container["lxc_name"] .
			' -- bash -c "sed -i -re \'s/^(mesg n)(.*)$/#\1\2/g\' /root/.profile"',
	);

	# Use LE sandbox server, prevents hitting rate limits
	system(
		"lxc exec " .
			$container["lxc_name"] .
			' -- bash -c "sed -i \'/LE_STAGING/d\' /usr/local/david/conf/david.conf"',
	);
	system(
		"lxc exec " .
			$container["lxc_name"] .
			' -- bash -c "echo \'LE_STAGING=\"yes\"\' >> /usr/local/david/conf/david.conf"',
	);

	system("lxc exec " . $container["lxc_name"] . ' -- bash -c "service david restart"');
}

echo "David containers configured" . PHP_EOL;

