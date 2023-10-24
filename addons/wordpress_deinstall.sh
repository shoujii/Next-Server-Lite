#!/bin/bash

deinstall_wordpress() {

MYSQL_ROOT_PASS=$(grep -Pom 1 "(?<=^MYSQL_ROOT_PASS: ).*$" /root/NeXt-Server-Lite/login_information.txt)
WORDPRESS_DB_NAME=$(grep -Pom 1 "(?<=^WordpressDBName = ).*$" /root/NeXt-Server-Lite/wordpress_login_data.txt)
WordpressDBUser=$(grep -Pom 1 "(?<=^WordpressDBUser = ).*$" /root/NeXt-Server-Lite/wordpress_login_data.txt)
WordpressScriptPath=$(grep -Pom 1 "(?<=^WordpressScriptPath = ).*$" /root/NeXt-Server-Lite/wordpress_login_data.txt)

mysql -u root -p${MYSQL_ROOT_PASS} -e "DROP DATABASE IF EXISTS ${WORDPRESS_DB_NAME};"
mysql -u root -p${MYSQL_ROOT_PASS} -e "DROP USER ${WordpressDBUser}@localhost;"

if [ "$WORDPRESS_PATH_NAME" != "root" ]; then
  rm -rf /var/www/${MYDOMAIN}/public/${WordpressScriptPath}
else
  rm -R /var/www/${MYDOMAIN}/public/wp-admin/
  rm -R /var/www/${MYDOMAIN}/public/wp-content/
  rm -R /var/www/${MYDOMAIN}/public/wp-includes/
  rm /var/www/${MYDOMAIN}/public/{license.txt,readme.html,wp-activate.php,wp-blog-header.php,wp-config.php,wp-load.php,wp-mail.php,wp-signup.php,xmlrpc.php,index.php,wp-comments-post.php,wp-config-sample.php,wp-cron.php,wp-links-opml.php,wp-login.php,wp-settings.php,wp-trackback.php}
  cp /var/www/${MYDOMAIN}/public/index-files-backup/* /var/www/${MYDOMAIN}/public/
  rm -R /var/www/${MYDOMAIN}/public/index-files-backup/
fi

rm /root/NeXt-Server-Lite/wordpress_login_data.txt
rm /etc/nginx/_wordpress.conf
sed_replace_word "include _wordpress.conf;" "#include _wordpress.conf;" "/etc/nginx/sites-available/${MYDOMAIN}.conf"

systemctl -q restart php$PHPVERSION8-fpm.service
systemctl -q restart nginx.service

sed_replace_word "$WORDPRESS_PATH_NAME" "" "/root/NeXt-Server-Lite/configs/blocked_paths.conf"
sed_replace_word "WORDPRESS_PATH_NAME=\".*"\" "WORDPRESS_PATH_NAME=\"0"\" "/root/NeXt-Server-Lite/configs/userconfig.cfg"
sed_replace_word "WORDPRESS_IS_INSTALLED=\"1"\" "WORDPRESS_IS_INSTALLED=\"0"\" "/root/NeXt-Server-Lite/configs/userconfig.cfg"
}