#!/bin/bash

check_system() {

failed_system_checks=0
passed_system_checks=0

if [ -e /etc/hosts ]; then
  passed_system_checks=$((passed_system_checks + 1))
else
  failed_system_checks=$((failed_system_checks + 1))
  echo "${error} hosts does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/mailname ]; then
  passed_system_checks=$((passed_system_checks + 1))
else
  failed_system_checks=$((failed_system_checks + 1))
  echo "${error} mailname does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/apt/sources.list ]; then
  passed_system_checks=$((passed_system_checks + 1))
else
  failed_system_checks=$((failed_system_checks + 1))
  echo "${error} sources.list does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/sysctl.conf ]; then
  passed_system_checks=$((passed_system_checks + 1))
else
  failed_system_checks=$((failed_system_checks + 1))
  echo "${error} sysctl.conf does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/cron.daily/webserver_backup ]; then
  passed_system_checks=$((passed_system_checks + 1))
else
  failed_system_checks=$((failed_system_checks + 1))
  echo "${error} webserver_backup cron does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/cron.daily/free_disk_space ]; then
  passed_system_checks=$((passed_system_checks + 1))
else
  failed_system_checks=$((failed_system_checks + 1))
  echo "${error} free_disk_space cron does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/cron.daily/webserver_backup ]; then
  passed_system_checks=$((passed_system_checks + 1))
else
  failed_system_checks=$((failed_system_checks + 1))
  echo "${error} webserver_backup cron does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /etc/cron.d/le_cert_alert ]; then
  passed_system_checks=$((passed_system_checks + 1))
else
  failed_system_checks=$((failed_system_checks + 1))
  echo "${error} le_cert_alert cron does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /root/NeXt-Server-Bookworm/login_information.txt ]; then
  passed_system_checks=$((passed_system_checks + 1))
else
  failed_system_checks=$((failed_system_checks + 1))
  echo "${error} login_information.txt does NOT exist" >>"${failed_checks_log}"
fi

if [ -e /root/NeXt-Server-Bookworm/dns_settings.txt ]; then
  passed_system_checks=$((passed_system_checks + 1))
else
  failed_system_checks=$((failed_system_checks + 1))
  echo "${error} dns_settings.txt does NOT exist" >>"${failed_checks_log}"
fi

echo "System:"
echo "${ok} ${passed_system_checks} checks passed!"

if [[ "${failed_system_checks}" != "0" ]]; then
  echo "${error} ${failed_system_checks} check/s failed! Please check /root/NeXt-Server-Bookworm/logs/failed_checks.log or consider a new installation!"
fi
echo ""
}
