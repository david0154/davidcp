; origin-src: deb/php-fpm/multiphp.tpl
;#=========================================================================#
;# Default Web Domain Template                                             #
;# DO NOT MODIFY THIS FILE! CHANGES WILL BE LOST WHEN REBUILDING DOMAINS   #
;# https://davidk.online/docs/server-administration/web-templates.html      #
;#=========================================================================#

[%domain%]
listen = /run/php/php%backend_version%-fpm-%domain%.sock
listen.owner = %user%
listen.group = www-data
listen.mode = 0660

user = %user%
group = %user%

pm = ondemand
pm.max_children = 8
pm.max_requests = 4000
pm.process_idle_timeout = 10s
pm.status_path = /status

php_admin_value[upload_tmp_dir] = /home/%user%/tmp
php_admin_value[session.save_path] = /home/%user%/tmp
php_admin_value[open_basedir] = /home/%user%/.composer:/home/%user%/web/%domain%/public_html:/home/%user%/web/%domain%/private:/home/%user%/web/%domain%/public_shtml:/home/%user%/tmp:/tmp:/var/www/html:/bin:/usr/bin:/usr/local/bin:/usr/share:/opt
php_admin_value[sendmail_path] = /usr/sbin/sendmail -t -i -f admin@%domain%

env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /home/%user%/tmp
env[TMPDIR] = /home/%user%/tmp
env[TEMP] = /home/%user%/tmp
