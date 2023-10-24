#!/bin/bash

install_wordpress() {

trap error_exit ERR

source /root/NeXt-Server-Lite/configs/sources.cfg
get_domain

WORDPRESS_USER=$(username)
WORDPRESS_DB_NAME=$(username)
WORDPRESS_DB_PASS=$(password)
WORDPRESS_DB_PREFIX=$(username)
MYSQL_ROOT_PASS=$(grep -Pom 1 "(?<=^MYSQL_ROOT_PASS: ).*$" /root/NeXt-Server-Lite/login_information.txt)

mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE DATABASE ${WORDPRESS_DB_NAME};"
mysql -u root -p${MYSQL_ROOT_PASS} -e "CREATE USER ${WORDPRESS_USER}@localhost IDENTIFIED BY '${WORDPRESS_DB_PASS}';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "GRANT ALL PRIVILEGES ON ${WORDPRESS_DB_NAME}.* TO '${WORDPRESS_USER}'@'localhost';"
mysql -u root -p${MYSQL_ROOT_PASS} -e "FLUSH PRIVILEGES;"

cd /var/www/${MYDOMAIN}/public/
wget_tar "https://wordpress.org/latest.tar.gz"
tar -zxvf latest.tar.gz
rm latest.tar.gz

if [ "$WORDPRESS_PATH_NAME" != "root" ]; then
  if [ "$WORDPRESS_PATH_NAME" == "wordpress" ]; then
    cd wordpress
  else
    mv wordpress ${WORDPRESS_PATH_NAME}
    cd ${WORDPRESS_PATH_NAME}
  fi
else
  mkdir -p /var/www/${MYDOMAIN}/public/index-files-backup
  if [ -f /var/www/${MYDOMAIN}/public/index.php ]; then
     mv /var/www/${MYDOMAIN}/public/index.php /var/www/${MYDOMAIN}/public/index-files-backup
  fi
  if [ -f /var/www/${MYDOMAIN}/public/index.html ]; then
     mv /var/www/${MYDOMAIN}/public/index.html /var/www/${MYDOMAIN}/public/index-files-backup
  fi
  mv /var/www/${MYDOMAIN}/public/wordpress/* /var/www/${MYDOMAIN}/public/
  rm -R /var/www/${MYDOMAIN}/public/wordpress/
fi
cp wp-config-sample.php wp-config.php

sed_replace_word "wp_" "${WORDPRESS_DB_PREFIX}_" "wp-config.php"
sed_replace_word "database_name_here" "${WORDPRESS_DB_NAME}" "wp-config.php"
sed_replace_word "username_here" "${WORDPRESS_USER}" "wp-config.php"
sed_replace_word "password_here" "${WORDPRESS_DB_PASS}" "wp-config.php"

salts=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
while read -r salt; do
  search="define('$(echo "$salt" | cut -d "'" -f 2)"
  replace=$(echo "$salt" | cut -d "'" -f 4)
    sed -i "/^$search/s/put your unique phrase here/$(echo $replace | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')/" wp-config.php
done <<< "$salts"

if [ "$WORDPRESS_PATH_NAME" != "root" ]; then
  mkdir -p /var/www/${MYDOMAIN}/public/${WORDPRESS_PATH_NAME}/wp-content/uploads
else
  mkdir -p /var/www/${MYDOMAIN}/public/wp-content/uploads
fi

chown www-data:www-data -R *
find . -type f -exec chmod 644 {} \;
find . -type d -exec chmod 755 {} \;

cp /root/NeXt-Server-Lite/addons/vhosts/_wordpress.conf /etc/nginx/_wordpress.conf
sed_replace_word "#include _wordpress.conf;" "include _wordpress.conf;" "/etc/nginx/sites-available/${MYDOMAIN}.conf"

touch /root/NeXt-Server-Lite/wordpress_login_data.txt
echo "--------------------------------------------" >> /root/NeXt-Server-Lite/wordpress_login_data.txt
echo "Wordpress" >> /root/NeXt-Server-Lite/wordpress_login_data.txt
echo "--------------------------------------------" >> /root/NeXt-Server-Lite/wordpress_login_data.txt
if [ "$WORDPRESS_PATH_NAME" != "root" ]; then
  echo "https://${MYDOMAIN}/${WORDPRESS_PATH_NAME}" >> /root/NeXt-Server-Lite/wordpress_login_data.txt
else
  echo "https://${MYDOMAIN}/" >> /root/NeXt-Server-Lite/wordpress_login_data.txt
fi
echo "WordpressDBUser = ${WORDPRESS_USER}" >> /root/NeXt-Server-Lite/wordpress_login_data.txt
echo "WordpressDBName = ${WORDPRESS_DB_NAME}" >> /root/NeXt-Server-Lite/wordpress_login_data.txt
echo "WordpressDBPassword = ${WORDPRESS_DB_PASS}" >> /root/NeXt-Server-Lite/wordpress_login_data.txt
echo "WordpressScriptPath = ${WORDPRESS_PATH_NAME}" >> /root/NeXt-Server-Lite/wordpress_login_data.txt

sed_replace_word "WORDPRESS_IS_INSTALLED=\"0"\" "WORDPRESS_IS_INSTALLED=\"1"\" "/root/NeXt-Server-Lite/configs/userconfig.cfg"
echo "$WORDPRESS_PATH_NAME" >> /root/NeXt-Server-Lite/configs/blocked_paths.conf

systemctl -q restart php$PHPVERSION8-fpm.service
systemctl restart nginx

dialog_msg "Please save the shown login information on next page"
cat /root/NeXt-Server-Lite/wordpress_login_data.txt
continue_or_exit
}