#!/bin/bash

# David Control Panel upgrade script for target version 1.9.0

#######################################################################################
#######                      Place additional commands below.                   #######
#######################################################################################
####### upgrade_config_set_value only accepts true or false.                    #######
#######                                                                         #######
####### Pass through information to the end user in case of a issue or problem  #######
#######                                                                         #######
####### Use add_upgrade_message "My message here" to include a message          #######
####### in the upgrade notification email. Example:                             #######
#######                                                                         #######
####### add_upgrade_message "My message here"                                   #######
#######                                                                         #######
####### You can use \n within the string to create new lines.                   #######
#######################################################################################

upgrade_config_set_value 'UPGRADE_UPDATE_WEB_TEMPLATES' 'false'
upgrade_config_set_value 'UPGRADE_UPDATE_DNS_TEMPLATES' 'false'
upgrade_config_set_value 'UPGRADE_UPDATE_MAIL_TEMPLATES' 'false'
upgrade_config_set_value 'UPGRADE_REBUILD_USERS' 'no'
upgrade_config_set_value 'UPGRADE_UPDATE_FILEMANAGER_CONFIG' 'false'

# Delete all ssh keys for the filemanager make sure davidweb can read them.
for user in $($BIN/v-list-sys-users plain); do
	if [ -f /home/$user/.ssh/dvp-filemanager-key ]; then
		# Remove old filemanager key
		rm -f /home/$user/.ssh/dvp-filemanager-key
	fi
done

# Update permissiosn /usr/local/david/data/sessions
chown -R davidweb:davidweb /usr/local/david/data/sessions

if [ -n "$DB_PGA_ALIAS" ]; then
	if [ -n "$DB_PMA_ALIAS" ]; then
		if [ "$DB_PMA_ALIAS" == "$DB_PGA_ALIAS" ]; then
			$BIN/v-change-sys-db-alias pga "phppgadmin"
		fi
	fi
fi

# Change owner of backups
chown -R davidweb /backup/*.tar

# Fix typo in www.conf
find /etc/php/ /usr/local/david/install/deb/php-fpm -type f -name 'www.conf' -print0 | xargs -0 -I {} sed -i 's/\[wwww\]/\[www\]/' {}
find /etc/php/ /usr/local/david/install/deb/php-fpm -type f -name 'dummy.conf' -print0 | xargs -0 -I {} sed -i 's/\[wwww\]/\[www\]/' {}
