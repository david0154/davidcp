#=========================================================================#
# Default Web Domain Template                                             #
# DO NOT MODIFY THIS FILE! CHANGES WILL BE LOST WHEN REBUILDING DOMAINS   #
# https://davidk.online/docs/server-administration/web-templates.html      #
#=========================================================================#

server {
	listen      %ip%:%proxy_port%;
	server_name %domain_idn% %alias_idn%;
	error_log   /var/log/%web_system%/domains/%domain%.error.log error;

	include %home%/%user%/conf/web/%domain%/nginx.forcessl.conf*;

	location ~ /\.(?!well-known\/|file) {
		deny all;
		return 404;
	}

	location / {
		proxy_pass http://%ip%:%web_port%;

		location ~* ^.+\.(%proxy_extensions%)$ {
			try_files  $uri @fallback;

			root       %docroot%;
			access_log /var/log/%web_system%/domains/%domain%.log combined;
			access_log /var/log/%web_system%/domains/%domain%.bytes bytes;

			expires    max;
		}
	}

	location @fallback {
		proxy_pass http://%ip%:%web_port%;
	}

	location /error/ {
		alias %home%/%user%/web/%domain%/document_errors/;
	}

	disable_symlinks if_not_owner from=%docroot%;

	include %home%/%user%/conf/web/%domain%/nginx.conf_*;
}
