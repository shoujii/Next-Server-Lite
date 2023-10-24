#!/bin/bash

install_munin() {

trap error_exit ERR

source /root/NeXt-Server-Lite/configs/sources.cfg

install_packages "munin munin-node munin-plugins-extra"

MUNIN_HTTPAUTH_USER=$(username)
MUNIN_HTTPAUTH_PASS=$(password)
htpasswd -b /etc/nginx/htpasswd/.htpasswd ${MUNIN_HTTPAUTH_USER} ${MUNIN_HTTPAUTH_PASS}

cp /root/NeXt-Server-Lite/addons/vhosts/_munin.conf /etc/nginx/_munin.conf
sed_replace_word "#include _munin.conf;" "include _munin.conf;" "/etc/nginx/sites-available/${MYDOMAIN}.conf"
sed_replace_word "localhost.localdomain" "mail.${MYDOMAIN}" "/etc/munin/munin.conf"
sed_replace_word "change_path" "${MUNIN_PATH_NAME}" "/etc/nginx/_munin.conf"

touch /root/NeXt-Server-Lite/munin_login_data.txt
echo "--------------------------------------------" >> /root/NeXt-Server-Lite/munin_login_data.txt
echo "Munin" >> /root/NeXt-Server-Lite/munin_login_data.txt
echo "--------------------------------------------" >> /root/NeXt-Server-Lite/munin_login_data.txt
echo "Warning: It can take several minutes (or a restart), until the URL is working! (403 Error)" >> /root/NeXt-Server-Lite/munin_login_data.txt
echo "Munin Address: ${MYDOMAIN}/${MUNIN_PATH_NAME}/" >> /root/NeXt-Server-Lite/munin_login_data.txt
echo "MUNIN_HTTPAUTH_USER = ${MUNIN_HTTPAUTH_USER}" >> /root/NeXt-Server-Lite/munin_login_data.txt
echo "MUNIN_HTTPAUTH_PASS = ${MUNIN_HTTPAUTH_PASS}" >> /root/NeXt-Server-Lite/munin_login_data.txt

sed_replace_word "MUNIN_IS_INSTALLED=\"0"\" "MUNIN_IS_INSTALLED=\"1"\" "/root/NeXt-Server-Lite/configs/userconfig.cfg"
echo "$MUNIN_PATH_NAME" >> /root/NeXt-Server-Lite/configs/blocked_paths.conf

systemctl -q restart php$PHPVERSION8-fpm.service
systemctl -q restart munin-node 
systemctl -q restart nginx.service

dialog_msg "Please save the shown login information on next page"
cat /root/NeXt-Server-Lite/munin_login_data.txt
continue_or_exit
}