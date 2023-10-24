#!/bin/bash

install_nextcloud() {

trap error_exit ERR

source /root/NeXt-Server-Lite/configs/sources.cfg

install_packages "unzip php-gmp imagemagick"

MYSQL_ROOT_PASS=$(grep -Pom 1 "(?<=^MYSQL_ROOT_PASS: ).*$" /root/NeXt-Server-Lite/login_information.txt)
NEXTCLOUD_USER=$(username)
NEXTCLOUD_DB_PASS=$(password)
NEXTCLOUD_DB_NAME=$(username)

mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE DATABASE ${NEXTCLOUD_DB_NAME};"
mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE USER '${NEXTCLOUD_USER}'@'localhost' IDENTIFIED BY '${NEXTCLOUD_DB_PASS}';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "GRANT ALL PRIVILEGES ON ${NEXTCLOUD_DB_NAME}.* TO '${NEXTCLOUD_USER}'@'localhost';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "FLUSH PRIVILEGES;"

cd /var/www/${MYDOMAIN}/public/
wget_tar "https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.zip"
unzip_file "nextcloud-${NEXTCLOUD_VERSION}.zip"
rm nextcloud-${NEXTCLOUD_VERSION}.zip

if [ "$NEXTCLOUD_PATH_NAME" == "nextcloud" ]; then
  cd nextcloud
else
  mv nextcloud ${NEXTCLOUD_PATH_NAME}
  cd ${NEXTCLOUD_PATH_NAME}
fi

chown -R www-data:www-data /var/www/${MYDOMAIN}/public/${NEXTCLOUD_PATH_NAME}

cp /root/NeXt-Server-Lite/addons/vhosts/_nextcloud.conf /etc/nginx/_nextcloud.conf
sed_replace_word "#include _nextcloud.conf;" "include _nextcloud.conf;" "/etc/nginx/sites-available/${MYDOMAIN}.conf"
sed_replace_word "change_path" "${NEXTCLOUD_PATH_NAME}" "/etc/nginx/_nextcloud.conf"

touch /root/NeXt-Server-Lite/nextcloud_login_data.txt
echo "--------------------------------------------" >> /root/NeXt-Server-Lite/nextcloud_login_data.txt
echo "Nextcloud" >> /root/NeXt-Server-Lite/nextcloud_login_data.txt
echo "--------------------------------------------" >> /root/NeXt-Server-Lite/nextcloud_login_data.txt
echo "https://${MYDOMAIN}/${NEXTCLOUD_PATH_NAME}" >> /root/NeXt-Server-Lite/nextcloud_login_data.txt
echo "NextcloudDBUser = ${NEXTCLOUD_USER}" >> /root/NeXt-Server-Lite/nextcloud_login_data.txt
echo "Database password = ${NEXTCLOUD_DB_PASS}" >> /root/NeXt-Server-Lite/nextcloud_login_data.txt
echo "NextcloudDBName = ${NEXTCLOUD_DB_NAME}" >> /root/NeXt-Server-Lite/nextcloud_login_data.txt

sed_replace_word "NEXTCLOUD_IS_INSTALLED=\"0"\" "NEXTCLOUD_IS_INSTALLED=\"1"\" "/root/NeXt-Server-Lite/configs/userconfig.cfg"
echo "$NEXTCLOUD_PATH_NAME" >> /root/NeXt-Server-Lite/configs/blocked_paths.conf

systemctl -q restart php$PHPVERSION8-fpm.service
systemctl -q reload nginx.service

dialog_msg "Please save the shown login information on next page"
cat /root/NeXt-Server-Lite/nextcloud_login_data.txt
continue_or_exit
}