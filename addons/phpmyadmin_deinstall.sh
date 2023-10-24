#!/bin/bash

deinstall_phpmyadmin() {

trap error_exit ERR

MYSQL_ROOT_PASS=$(grep -Pom 1 "(?<=^MYSQL_ROOT_PASS: ).*$" /root/NeXt-Server-Lite/login_information.txt)
mysql -u root -p${MYSQL_ROOT_PASS} -e "DROP DATABASE IF EXISTS phpmyadmin;"

PMA_HTTPAUTH_DELETE_USER=$(grep -Pom 1 "(?<=^PMA_HTTPAUTH_USER = ).*$" /root/NeXt-Server-Lite/phpmyadmin_login_data.txt)
htpasswd -D /etc/nginx/htpasswd/.htpasswd ${PMA_HTTPAUTH_DELETE_USER}

rm -rf /var/www/${MYDOMAIN}/public/${PHPMYADMIN_PATH_NAME}
rm /root/NeXt-Server-Lite/phpmyadmin_login_data.txt
rm /etc/nginx/_phpmyadmin.conf

sed_replace_word "include _phpmyadmin.conf;" "#include _phpmyadmin.conf;" "/etc/nginx/sites-available/${MYDOMAIN}.conf"

systemctl -q restart php$PHPVERSION8-fpm.service
systemctl -q restart nginx.service

sed_replace_word "$PHPMYADMIN_PATH_NAME" "" "/root/NeXt-Server-Lite/configs/blocked_paths.conf"
sed_replace_word "PMA_IS_INSTALLED=\"1"\" "PMA_IS_INSTALLED=\"0"\" "/root/NeXt-Server-Lite/configs/userconfig.cfg"
sed_replace_word "PHPMYADMIN_PATH_NAME=\".*"\" "PHPMYADMIN_PATH_NAME=\"0"\" "/root/NeXt-Server-Lite/configs/userconfig.cfg"
}