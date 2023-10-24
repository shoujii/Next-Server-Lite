#!/bin/bash

install_nginx() {

trap error_exit ERR

install_packages "psmisc libpcre3 libpcre3-dev libgeoip-dev zlib1g-dev"

cd /root/NeXt-Server-Lite/sources
wget_tar "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz"
tar_file "nginx-${NGINX_VERSION}.tar.gz"
cd nginx-${NGINX_VERSION} 

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
--with-http_v3_module \
--with-openssl=/root/NeXt-Server-Lite/sources/libressl-${LIBRESSL_VERSION}"

./configure $NGINX_OPTIONS $NGINX_MODULES --with-cc-opt='-O2 -g -pipe -Wall -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong -m64 -mtune=generic' >>"${make_log}" 2>>"${make_err_log}"
make -j $(nproc) >>"${make_log}" 2>>"${make_err_log}"  
make install >>"${make_log}" 2>>"${make_err_log}" 

rm -R /root/NeXt-Server-Lite/sources/nginx-${NGINX_VERSION}

mkdir -p /var/lib/nginx/{body,proxy,fastcgi,uwsgi,scgi}
mkdir -p /etc/nginx/{sites,ssl,sites-available,sites-enabled,htpasswd}

touch /etc/nginx/htpasswd/.htpasswd
mkdir -p /var/www/${MYDOMAIN}/public
mkdir -p /var/cache/nginx
mkdir -p /var/log/nginx/

cp /root/NeXt-Server-Lite/configs/nginx/confs/nginx.service /lib/systemd/system/
systemctl enable nginx.service

rm -rf /etc/nginx/nginx.conf
cp /root/NeXt-Server-Lite/configs/nginx/confs/* /etc/nginx/

rm -rf /etc/nginx/sites-available/${MYDOMAIN}.conf
cp /root/NeXt-Server-Lite/configs/nginx/vhost /etc/nginx/sites-available/${MYDOMAIN}.conf
sed_replace_word "MYDOMAIN" "${MYDOMAIN}" "/etc/nginx/sites-available/${MYDOMAIN}.conf"

if [[ ${IPV4_ONLY} = "1" ]]; then
  sed_replace_word "IPADR" "${IPADR}" "/etc/nginx/sites-available/${MYDOMAIN}.conf"
fi

if [[ ${IPV6_ONLY} = "1" ]]; then
### doesn't work at all, bc hes adding ipv4 too	
  sed_replace_word "IPADR" ":" "/etc/nginx/sites-available/${MYDOMAIN}.conf"
  sed_replace_word "IP6ADR" "${IP6ADR}" "/etc/nginx/sites-available/${MYDOMAIN}.conf"
fi

if [[ ${IP_DUAL} == '1' ]]; then
  sed_replace_word "IPADR" "${IPADR}" "/etc/nginx/sites-available/${MYDOMAIN}.conf"
  sed_replace_word "IP6ADR" "${IP6ADR}" "/etc/nginx/sites-available/${MYDOMAIN}.conf"
fi

chown -R www-data:www-data /var/www/${MYDOMAIN}/public
ln -s /etc/nginx/sites-available/${MYDOMAIN}.conf /etc/nginx/sites-enabled/${MYDOMAIN}.conf

cp /root/NeXt-Server-Lite/includes/NeXt-logo.jpg /var/www/${MYDOMAIN}/public/NeXt-logo.jpg
cp /root/NeXt-Server-Lite/configs/nginx/index.html /var/www/${MYDOMAIN}/public/index.html
}