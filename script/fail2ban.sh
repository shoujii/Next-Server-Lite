#!/bin/bash

install_fail2ban() {

trap error_exit ERR

install_packages "fail2ban"

cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local 
cp /root/NeXt-Server-Lite/configs/fail2ban/jail.local /etc/fail2ban/jail.local

#cp files/debian-initd /etc/init.d/fail2ban 
#update-rc.d fail2ban defaults 
systemctl -q start fail2ban
}