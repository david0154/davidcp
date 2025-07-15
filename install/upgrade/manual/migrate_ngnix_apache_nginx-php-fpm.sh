#!/bin/bash

# Function Description
# Manual upgrade script from Nginx + Apache2 + PHP-FPM to Nginx + PHP-FPM

#----------------------------------------------------------#
#                    Variable&Function                     #
#----------------------------------------------------------#

# Includes
# shellcheck source=/etc/davidcp/david.conf
source /etc/davidcp/david.conf
# shellcheck source=/usr/local/david/func/main.sh
source $HESTIA/func/main.sh
# shellcheck source=/usr/local/david/conf/david.conf
source $HESTIA/conf/david.conf

#----------------------------------------------------------#
#                    Verifications                         #
#----------------------------------------------------------#

if [ "$WEB_BACKEND" != "php-fpm" ]; then
	check_result $E_NOTEXISTS "PHP-FPM is not enabled" > /dev/null
	exit 1
fi

if [ "$WEB_SYSTEM" != "apache2" ]; then
	check_result $E_NOTEXISTS "Apache2 is not enabled" > /dev/null
	exit 1
fi

#----------------------------------------------------------#
#                       Action                             #
#----------------------------------------------------------#

# Remove apache2 from config
sed -i "/^WEB_PORT/d" $HESTIA/conf/david.conf $HESTIA/conf/defaults/david.conf
sed -i "/^WEB_SSL/d" $HESTIA/conf/david.conf $HESTIA/conf/defaults/david.conf
sed -i "/^WEB_SSL_PORT/d" $HESTIA/conf/david.conf $HESTIA/conf/defaults/david.conf
sed -i "/^WEB_RGROUPS/d" $HESTIA/conf/david.conf $HESTIA/conf/defaults/david.conf
sed -i "/^WEB_SYSTEM/d" $HESTIA/conf/david.conf $HESTIA/conf/defaults/david.conf

# Remove nginx (proxy) from config
sed -i "/^PROXY_PORT/d" $HESTIA/conf/david.conf $HESTIA/conf/defaults/david.conf
sed -i "/^PROXY_SSL_PORT/d" $HESTIA/conf/david.conf $HESTIA/conf/defaults/david.conf
sed -i "/^PROXY_SYSTEM/d" $HESTIA/conf/david.conf $HESTIA/conf/defaults/david.conf

# Add Nginx settings to config
echo "WEB_PORT='80'" >> $HESTIA/conf/david.conf
echo "WEB_SSL='openssl'" >> $HESTIA/conf/david.conf
echo "WEB_SSL_PORT='443'" >> $HESTIA/conf/david.conf
echo "WEB_SYSTEM='nginx'" >> $HESTIA/conf/david.conf

# Add Nginx settings to config
echo "WEB_PORT='80'" >> $HESTIA/conf/defaults/david.conf
echo "WEB_SSL='openssl'" >> $HESTIA/conf/defaults/david.conf
echo "WEB_SSL_PORT='443'" >> $HESTIA/conf/defaults/david.conf
echo "WEB_SYSTEM='nginx'" >> $HESTIA/conf/defaults/david.conf

rm $HESTIA/conf/defaults/david.conf
cp $HESTIA/conf/david.conf $HESTIA/conf/defaults/david.conf

# Rebuild web config

for user in $($BIN/v-list-users plain | cut -f1); do
	echo $user
	for domain in $($BIN/v-list-web-domains $user plain | cut -f1); do
		$BIN/v-change-web-domain-tpl $user $domain 'default'
		$BIN/v-rebuild-web-domain $user $domain no
	done
done

systemctl restart nginx
