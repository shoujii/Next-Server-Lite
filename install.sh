#!/bin/bash

source /root/NeXt-Server-Lite/configs/sources.cfg

install_start=`date +%s`

#progress_gauge "0" "Checking your system..."
set_logs
prerequisites
setipaddrvars
check_system_before_start

confighelper_userconfig

mkdir /root/NeXt-Server-Lite/sources
#progress_gauge "0" "Installing System..."
install_system

#progress_gauge "1" "Installing LibreSSL..."
install_libressl

#progress_gauge "31" "Installing OpenSSH..."
install_openssh

#progress_gauge "32" "Installing fail2ban..."
install_fail2ban

#progress_gauge "33" "Installing MariaDB..."
install_mariadb

#progress_gauge "40" "Installing Nginx..."
install_nginx

#progress_gauge "65" "Installing Let's Encrypt..."
install_lets_encrypt

#progress_gauge "68" "Creating Let's Encrypt Certificate..."
create_nginx_cert

#progress_gauge "74" "Installing PHP..."
install_php_8_2

#progress_gauge "96" "Installing Firewall..."
install_firewall

install_end=`date +%s`
runtime=$((install_end-install_start))

sed -i 's/NXT_IS_INSTALLED="0"/NXT_IS_INSTALLED="1"/' /root/NeXt-Server-Lite/configs/userconfig.cfg

date=$(date +"%d-%m-%Y")
sed -i 's/NXT_INSTALL_DATE="0"/NXT_INSTALL_DATE="'${date}'"/' /root/NeXt-Server-Lite/configs/userconfig.cfg
sed -i 's/NXT_INSTALL_TIME_SECONDS="0"/NXT_INSTALL_TIME_SECONDS="'${runtime}'"/' /root/NeXt-Server-Lite/configs/userconfig.cfg

start_after_install