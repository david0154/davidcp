#=========================================================================#
# Default Web Domain Template                                             #
# DO NOT MODIFY THIS FILE! CHANGES WILL BE LOST WHEN REBUILDING DOMAINS   #
# https://davidk.online/docs/server-administration/web-templates.html      #
#=========================================================================#

server {
	listen      %ip%:%web_port%;
	server_name %domain_idn% %alias_idn%;
	root        %docroot%;
	index       index.php index.html index.htm;
	access_log  /var/log/nginx/domains/%domain%.log combined;
	access_log  /var/log/nginx/domains/%domain%.bytes bytes;
	error_log   /var/log/nginx/domains/%domain%.error.log error;

	include %home%/%user%/conf/web/%domain%/nginx.forcessl.conf*;

	rewrite ^/(.*\.php)(/)(.*)$ /$1?file=/$3 last;

	location = /favicon.ico {
		log_not_found off;
		access_log off;
	}

	location = /robots.txt {
		allow all;
		log_not_found off;
		access_log off;
	}

	# Very rarely should these ever be accessed outside of your lan
	location ~* \.(txt|log)$ {
		allow 192.168.0.0/16;
		deny all;
	}

	# No no for private
	location ~ ^/sites/.*/private/ {
		return 403;
	}

	location ~ /\.(?!well-known\/) {
		deny all;
		return 404;
	}

	location / {
		location ~* ^.+\.(jpeg|jpg|png|webp|gif|bmp|ico|svg|css|js)$ {
			expires max;
			fastcgi_hide_header "Set-Cookie";
		}

		location ~ \..*/.*\.php$ {
			return 403;
		}

		location ~ [^/]\.php(/|$) {
			try_files $fastcgi_script_name =404;

			include /etc/nginx/fastcgi_params;

			fastcgi_index index.php;
			fastcgi_intercept_errors on;
			fastcgi_param PHP_VALUE open_basedir="/home/%user%/web/%domain%/private/moodledata:/home/%user%/web/%domain%/public_html:/home/%user%/web/%domain%/public_shtml:/home/%user%/tmp:/var/www/html:/etc/phpmyadmin:/var/lib/phpmyadmin:/etc/phppgadmin:/etc/roundcube:/var/lib/roundcube:/tmp:/bin:/usr/bin:/usr/local/bin:/usr/share:/opt";
			fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
			fastcgi_split_path_info ^(.+\.php)($|/.*);

			fastcgi_pass %backend_lsnr%;

			include %home%/%user%/conf/web/%domain%/nginx.fastcgi_cache.conf*;
		}
	}

	location /error/ {
		alias %home%/%user%/web/%domain%/document_errors/;
	}

	location /vstats/ {
		alias   %home%/%user%/web/%domain%/stats/;
		include %home%/%user%/web/%domain%/stats/auth.conf*;
	}

	include /etc/nginx/conf.d/phpmyadmin.inc*;
	include /etc/nginx/conf.d/phppgadmin.inc*;
	include %home%/%user%/conf/web/%domain%/nginx.conf_*;
}
