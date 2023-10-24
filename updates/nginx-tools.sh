#!/bin/bash

nginx_update_menu() {

trap error_exit ERR

source /root/NeXt-Server-Bookworm/configs/sources.cfg
set_logs

LATEST_NGINX_VERSION=$(curl -4sL https://nginx.org/en/download.html 2>&1 | egrep -o "nginx\-[0-9.]+\.tar[.a-z]*" | grep -v '.asc' | awk -F "nginx-" '/.tar.gz$/ {print $2}' | sed -e 's|.tar.gz||g' | head -n1 2>&1)
LOCAL_NGINX_VERSION=$(nginx -v 2>&1 | grep -o '[0-9.]*$')

if [[ ${LOCAL_NGINX_VERSION} != ${LATEST_NGINX_VERSION} ]]; then
BACKTITLE="NeXt Server Installation"
TITLE="NeXt Server Installation"
HEIGHT=15
WIDTH=70

CHOICE_HEIGHT=2
MENU="There is a new NGINX version ${LATEST_NGINX_VERSION} available!\nYour current version is ${LOCAL_NGINX_VERSION}\nDo you want to update?"
OPTIONS=(1 "Yes"
                 2 "No")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                                --no-cancel \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)
clear
case $CHOICE in
1)
backup_nginx
update_nginx
check_nginx
restore_nginx_backup
;;

2)
exit
;;
esac
fi
}

backup_nginx() {

  trap error_exit ERR

  ##maybe save old .deb for restoring nginx?
  systemctl -q stop nginx.service
  mkdir -p /etc/nginx/backup/
  mv -v /var/www/${MYDOMAIN}/public/* /etc/nginx/backup/
}

update_nginx() {

  trap error_exit ERR
  mkdir -p /root/NeXt-Server-Bookworm/updates/sources/

  cd /root/NeXt-Server-Bookworm/updates/sources/
  wget https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LIBRESSL_VERSION}.tar.gz
  tar -xzf libressl-${LIBRESSL_VERSION}.tar.gz

  systemctl -q stop nginx.service
  cd /root/NeXt-Server-Bookworm/updates/sources/
  wget_tar "https://nginx.org/download/nginx-${LATEST_NGINX_VERSION}.tar.gz"
  tar_file "nginx-${LATEST_NGINX_VERSION}.tar.gz"
  cd nginx-${LATEST_NGINX_VERSION}

  #Thanks to https://github.com/Angristan/nginx-autoinstall/
  NGINX_OPTIONS="
  --prefix=/etc/nginx \
  --sbin-path=/usr/sbin/nginx \
  --conf-path=/etc/nginx/nginx.conf \
  --error-log-path=/var/log/nginx/error.log \
  --http-log-path=/var/log/nginx/access.log \
  --pid-path=/var/run/nginx.pid \
  --lock-path=/var/run/nginx.lock \
  --http-client-body-temp-path=/var/lib/nginx/body \
  --http-proxy-temp-path=/var/lib/nginx/proxy \
  --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
  --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
  --http-scgi-temp-path=/var/lib/nginx/scgi \
  --user=www-data \
  --group=www-data"

  NGINX_MODULES="--without-http_browser_module \
  --without-http_empty_gif_module \
  --without-http_userid_module \
  --without-http_split_clients_module \
  --with-http_ssl_module \
  --with-http_gzip_static_module \
  --with-http_stub_status_module \
  --with-http_sub_module \
  --with-http_addition_module \
  --with-http_realip_module \
  --with-http_geoip_module \
  --with-threads \
  --with-stream \
  --with-stream_ssl_module \
  --with-pcre \
  --with-pcre-jit \
  --with-mail \
  --with-mail_ssl_module \
  --with-http_v2_module \
  --with-http_random_index_module \
  --with-http_auth_request_module \
  --with-http_secure_link_module \
  --with-http_flv_module \
  --with-http_dav_module \
  --with-http_mp4_module \
  --with-http_gunzip_module \
  --with-libressl-opt=enable-tls1_3 \
  --with-libressl=/root/NeXt-Server-Bookworm/updates/sources/libressl-${libressl_VERSION}"

  ./configure $NGINX_OPTIONS $NGINX_MODULES --with-cc-opt='-O2 -g -pipe -Wall -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong -m64 -mtune=generic'
  make -j $(nproc) >>"${make_log}" 2>>"${make_err_log}"
  make install >>"${make_log}" 2>>"${make_err_log}"

  sed_replace_word "NGINX_VERSION="'${NGINX_VERSION}'"" "NGINX_VERSION="'${LATEST_NGINX_VERSION}'"" "/root/NeXt-Server-Bookworm/configs/versions.cfg"
  ##create case for failed update + restore old version value?
  check_nginx
  continue_or_exit
}

restore_nginx_backup() {
  
  trap error_exit ERR
  mv -v /etc/nginx/backup/* /var/www/${MYDOMAIN}/public/
  systemctl -q start nginx.service
}