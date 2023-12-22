#!/bin/bash

install_system() {

trap error_exit ERR

source /root/NeXt-Server-Lite/configs/sources.cfg

rm /etc/network/interfaces
if [[ ${IPV4_ONLY} = "1" ]]; then
  cp -f /root/NeXt-Server-Lite/configs/IPv4.interface /etc/network/interfaces
  sed_replace_word "INTERFACENAME" "${INTERFACE}" "/etc/network/interfaces"
  sed_replace_word "IPV4ADDR" "${IPADR}" "/etc/network/interfaces"
  sed_replace_word "IPV4GATE" "${IPV4GAT}" "/etc/network/interfaces"
fi

if [[ ${IPV6_ONLY} = "1" ]]; then
  cp -f /root/NeXt-Server-Lite/configs/IPv6.interface /etc/network/interfaces
  sed_replace_word "INTERFACENAME" "${INTERFACE}" "/etc/network/interfaces"
  sed_replace_word "IPV6ADDR" "${IP6ADR}" "/etc/network/interfaces"
  sed_replace_word "IPV6GATE" "${IPV6GAT}" "/etc/network/interfaces"
  sed_replace_word "IPV6NET" "${IPV6NET}" "/etc/network/interfaces"
fi

if [[ ${IP_DUAL} = "1" ]]; then
  cp -f /root/NeXt-Server-Lite/configs/IPv4-IPv6.interface /etc/network/interfaces
  sed_replace_word "INTERFACENAME" "${INTERFACE}" "/etc/network/interfaces"
  sed_replace_word "IPV4ADDR" "${IPADR}" "/etc/network/interfaces"
  sed_replace_word "IPV4GATE" "${IPV4GAT}" "/etc/network/interfaces"
  sed_replace_word "IPV6ADDR" "${IP6ADR}" "/etc/network/interfaces"
  sed_replace_word "IPV6GATE" "${IPV6GAT}" "/etc/network/interfaces"
  sed_replace_word "IPV6NET" "${IPV6NET}" "/etc/network/interfaces"
fi

hostnamectl set-hostname --static mail

rm /etc/hosts
cat > /etc/hosts <<END
127.0.0.1   localhost
IPADR   mail.domain.tld  mail

::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
END
sed_replace_word "domain.tld" "${MYDOMAIN}" "/etc/hosts"
sed_replace_word "IPADR" "${IPADR}" "/etc/hosts"

echo $(hostname -f) > /etc/mailname

TIMEZONE_DETECTED=$(wget http://ip-api.com/line/${IPADR}?fields=timezone -q -O -)
timedatectl set-timezone ${TIMEZONE_DETECTED}

sed_replace_word "EMPTY_TIMEZONE" "${TIMEZONE_DETECTED}" "/root/NeXt-Server-Lite/configs/userconfig.cfg"

rm /etc/apt/sources.list
cat > /etc/apt/sources.list <<END
#------------------------------------------------------------------------------#
#                   OFFICIAL DEBIAN REPOS                                      #
#------------------------------------------------------------------------------#

###### Debian Main Repos
deb http://deb.debian.org/debian/ bookworm main
deb-src http://deb.debian.org/debian/ bookworm main

deb http://security.debian.org/debian-security bookworm-security main
deb-src http://security.debian.org/debian-security bookworm-security main

deb http://deb.debian.org/debian/ bookworm-updates main
deb-src http://deb.debian.org/debian/ bookworm-updates main

END

apt update -y >/dev/null 2>&1
apt -y upgrade >/dev/null 2>&1

install_packages "rsyslog haveged dirmngr curl software-properties-common sudo rkhunter debsecan debsums passwdqc unattended-upgrades needrestart apt-listchanges apache2-utils"
cp -f /root/NeXt-Server-Lite/configs/needrestart.conf /etc/needrestart/needrestart.conf
cp -f /root/NeXt-Server-Lite/configs/20auto-upgrades /etc/apt/apt.conf.d/20auto-upgrades
cp -f /root/NeXt-Server-Lite/configs/50unattended-upgrades /etc/apt/apt.conf.d/50unattended-upgrades
sed_replace_word "email_address=root" "email_address=${NXT_SYSTEM_EMAIL}" "/etc/apt/listchanges.conf"
sed_replace_word "changeme" "${NXT_SYSTEM_EMAIL}" "/etc/apt/apt.conf.d/50unattended-upgrades"

cp -f /root/NeXt-Server-Lite/cronjobs/webserver_backup /etc/cron.daily/
chmod +x /etc/cron.daily/webserver_backup
}