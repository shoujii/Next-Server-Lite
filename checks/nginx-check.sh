#!/bin/bash

check_nginx() {

failed_nginx_checks=0
passed_nginx_checks=0

if [ -e /lib/systemd/system/nginx.service ]; then
  passed_nginx_checks=$((passed_nginx_checks + 1))
else
  failed_nginx_checks=$((failed_nginx_checks + 1))
  echo "${error} nginx systemd does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/nginx/nginx.conf ]; then
  passed_nginx_checks=$((passed_nginx_checks + 1))
else
  failed_nginx_checks=$((failed_nginx_checks + 1))
  echo "${error} nginx.conf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/nginx/_general.conf ]; then
  passed_nginx_checks=$((passed_nginx_checks + 1))
else
  failed_nginx_checks=$((failed_nginx_checks + 1))
  echo "${error} _general.conf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/nginx/_php_fastcgi.conf ]; then
  passed_nginx_checks=$((passed_nginx_checks + 1))
else
  failed_nginx_checks=$((failed_nginx_checks + 1))
  echo "${error} _php_fastcgi.conf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /var/www/${MYDOMAIN}/public/NeXt-logo.jpg ]; then
  passed_nginx_checks=$((passed_nginx_checks + 1))
else
  failed_nginx_checks=$((failed_nginx_checks + 1))
  echo "${error} NeXt-logo.jpg does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /var/www/${MYDOMAIN}/public/index.html ]; then
  passed_nginx_checks=$((passed_nginx_checks + 1))
else
  failed_nginx_checks=$((failed_nginx_checks + 1))
  echo "${error} index.html does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/nginx/sites-enabled/${MYDOMAIN}.conf ]; then
  passed_nginx_checks=$((passed_nginx_checks + 1))
else
  failed_nginx_checks=$((failed_nginx_checks + 1))
  echo "${error} /sites-enabled/${MYDOMAIN}.conf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/nginx/sites-available/${MYDOMAIN}.conf ]; then
  passed_nginx_checks=$((passed_nginx_checks + 1))
else
  failed_nginx_checks=$((failed_nginx_checks + 1))
  echo "${error} /sites-available/${MYDOMAIN}.conf does NOT exist" >>"${failed_checks_log}"
fi

echo "Nginx:"
echo "${ok} ${passed_nginx_checks} checks passed!"

if [[ "${failed_nginx_checks}" != "0" ]]; then
  echo "${error} ${failed_nginx_checks} check/s failed! Please check /root/NeXt-Server-Bookworm/logs/failed_checks.log or consider a new installation!"
fi

#check config
nginx -t >/dev/null 2>&1
ERROR=$?
if [ "$ERROR" = '0' ]; then
  echo "${ok} The Nginx Config is working."
else
  echo "${error} The Nginx Config is NOT working."
fi

#check version
NGINX_VERSION=$(grep -Pom 1 "(?<=^NGINX_VERSION=).*$" /root/NeXt-Server-Bookworm/configs/versions.cfg)
NGINX_VERSION=$(echo "$NGINX_VERSION" | sed 's/\"//g')
LOCAL_NGINX_VERSION=$(nginx -v 2>&1 | grep -o '[0-9.]*$')
if [ $LOCAL_NGINX_VERSION != ${NGINX_VERSION} ]; then
  echo "${error} The installed Nginx Version $LOCAL_NGINX_VERSION is DIFFERENT with the Nginx Version ${NGINX_VERSION} defined in the Userconfig!"
else
	echo "${ok} The Nginx Version $LOCAL_NGINX_VERSION is equal with the Nginx Version ${NGINX_VERSION} defined in the Userconfig!"
fi

#check website
curl ${MYDOMAIN} -s -f -o /dev/null && echo "${ok} Website ${MYDOMAIN} is up and running." || echo "${error} Website ${MYDOMAIN} is down."

#check process
check_service "nginx"
echo ""
}
