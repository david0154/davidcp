#!/bin/bash

# David Control Panel upgrade script for target version 1.5.0

#######################################################################################
#######                      Place additional commands below.                   #######
#######################################################################################
####### Pass through information to the end user in case of a issue or problem  #######
#######                                                                         #######
####### Use add_upgrade_message "My message here" to include a message          #######
####### in the upgrade notification email. Example:                             #######
#######                                                                         #######
####### add_upgrade_message "My message here"                                   #######
#######                                                                         #######
####### You can use \n within the string to create new lines.                   #######
#######################################################################################

upgrade_config_set_value 'UPGRADE_UPDATE_WEB_TEMPLATES' 'true'
upgrade_config_set_value 'UPGRADE_UPDATE_DNS_TEMPLATES' 'true'
upgrade_config_set_value 'UPGRADE_UPDATE_MAIL_TEMPLATES' 'true'
upgrade_config_set_value 'UPGRADE_REBUILD_USERS' 'true'
upgrade_config_set_value 'UPGRADE_UPDATE_FILEMANAGER_CONFIG' 'true'

if [ -n "$DB_PMA_ALIAS" ]; then
	if [ -e "/etc/apache2/conf.d/phpmyadmin.conf" ]; then
		rm /etc/apache2/conf.d/phpmyadmin.conf
		touch /etc/apache2/conf.d/phpmyadmin.inc
	fi
	$DAVID/bin/v-change-sys-db-alias 'pma' "$DB_PMA_ALIAS"
fi

if [ -n "$DB_PGA_ALIAS" ]; then
	if [ -e "/etc/apache2/conf.d/phppgadmin.conf" ]; then
		rm /etc/apache2/conf.d/phppgadmin.conf
		touch /etc/apache2/conf.d/phppgadmin.inc
	fi
	$DAVID/bin/v-change-sys-db-alias 'pga' "$DB_PGA_ALIAS"

fi

if [ -n "$MAIL_SYSTEM" ]; then
	echo "[ ! ] Updating Exim configuration..."
	if [ -f "/etc/exim4/exim4.conf.template" ]; then
		sed -i 's/^smtp_active_hostname = \${if exists {\/etc\/exim4\/mailhelo\.conf}{\${lookup{\$interface_address}lsearch{\/etc\/exim4\/mailhelo\.conf}{\$value}{\$primary_hostname}}}{\$primary_hostname}}$/smtp_active_hostname = \${lookup dnsdb{>: ptr=\$interface_address}{\${listextract{1}{\$value}}}{\$primary_hostname}}/' /etc/exim4/exim4.conf.template

		sed -i 's/^  helo_data = \${if exists {\/etc\/exim4\/mailhelo\.conf}{\${lookup{\$sending_ip_address}lsearch{\/etc\/exim4\/mailhelo\.conf}{\$value}{\$primary_hostname}}}{\$primary_hostname}}$/  helo_data = \${lookup dnsdb{>: ptr=\$sending_ip_address}{\${listextract{1}{\$value}}}{\$primary_hostname}}/' /etc/exim4/exim4.conf.template

		# When 1.5.0 beta was installed
		sed -i 's/^smtp_active_hostname = \${lookup dnsdb{ptr=\$interface_address}{\$value}{\$primary_hostname}}$/smtp_active_hostname = \${lookup dnsdb{>: ptr=\$interface_address}{\${listextract{1}{\$value}}}{\$primary_hostname}}/' /etc/exim4/exim4.conf.template

		sed -i 's/^  helo_data = \${lookup dnsdb{ptr=\$sending_ip_address}{\$value}{\$primary_hostname}}$/  helo_data = \${lookup dnsdb{>: ptr=\$sending_ip_address}{\${listextract{1}{\$value}}}{\$primary_hostname}}/' /etc/exim4/exim4.conf.template
	fi

	# Clean up legacy mailhelo file
	rm -f /etc/${MAIL_SYSTEM}/mailhelo.conf

	# Clean up legacy ip variable
	for ip in $($BIN/v-list-sys-ips plain | cut -f1); do
		sed '/^HELO/d' $DAVID/data/ips/$ip > /dev/null
	done
fi

if [ -L "/var/log/david" ]; then
	echo "[ ! ] Updating log file location: /usr/local/david/log/* to /var/log/david/..."
	rm /var/log/david
	mkdir -p /var/log/david
	cp /usr/local/david/log/* /var/log/david/
	rm -rf /usr/local/david/log
	ln -s /var/log/david /usr/local/david/log
	touch /var/log/david/auth.log /var/log/david/error.log /var/log/david/system.log /var/log/david/nginx-error.log /var/log/david/nginx-access.log
fi

if [ -d "/var/log/roundcube" ]; then
	chown www-data:root /var/log/roundcube
	chmod 751 /var/log/roundcube
fi

if [ -d "/etc/roundcube" ]; then
	chmod 644 /etc/roundcube/defaults.inc.php
	chmod 644 /etc/roundcube/mimetypes.php
fi
