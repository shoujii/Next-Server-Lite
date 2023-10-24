#!/bin/bash

install_mariadb() {

trap error_exit ERR

MYSQL_ROOT_PASS=$(password)

debconf-set-selections <<< "mariadb-server mysql-server/root_password password ${MYSQL_ROOT_PASS}"
debconf-set-selections <<< "mariadb-server mysql-server/root_password_again password ${MYSQL_ROOT_PASS}"

install_packages "mariadb-server"

echo "#------------------------------------------------------------------------------#" >> /root/NeXt-Server-Lite/login_information.txt
echo "MYSQL_ROOT_PASS: $MYSQL_ROOT_PASS" >> /root/NeXt-Server-Lite/login_information.txt
echo "#------------------------------------------------------------------------------#" >> /root/NeXt-Server-Lite/login_information.txt
echo "" >> /root/NeXt-Server-Lite/login_information.txt

sed_replace_word ".*max_allowed_packet.*" "max_allowed_packet      = 128M" "/etc/mysql/conf.d/mysqldump.cnf"

mysql -u root -p${MYSQL_ROOT_PASS} -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASS}';" 
}