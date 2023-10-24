#!/bin/bash

confighelper_userconfig() {

# --- GLOBAL MENU VARIABLES ---
BACKTITLE="NeXt Server Installation"
TITLE="NeXt Server Installation"
HEIGHT=40
WIDTH=80

# --- MYDOMAIN ---
source /root/NeXt-Server-Lite/configs/sources.cfg
cp /root/NeXt-Server-Lite/configs/dns_settings.txt /root/NeXt-Server-Lite/dns_settings.txt
get_domain
CHECK_DOMAIN_LENGTH=`echo -n ${DETECTED_DOMAIN} | wc -m`

if [[ $CHECK_DOMAIN_LENGTH > 1 ]]; then
CHOICE_HEIGHT=2
MENU="Is this the domain, you want to use? ${DETECTED_DOMAIN}:"
OPTIONS=(1 "Yes"
         2 "No")
menu
clear
case $CHOICE in
1)
   MYDOMAIN=${DETECTED_DOMAIN}
;;
2)
while true
do
    MYDOMAIN=$(dialog --clear \
                      --backtitle "$BACKTITLE" \
                      --inputbox "Enter your Domain without http:// (exmaple.org):" \
                      $HEIGHT $WIDTH \
                      3>&1 1>&2 2>&3 3>&- \
                      )
    if [[ "$MYDOMAIN" =~ $CHECK_DOMAIN ]];then
        break
    else
        dialog_msg "[ERROR] Should we again practice how a Domain address looks?"
        dialog --clear
    fi
done
;;
esac
else
    dialog_msg "The Script wasn't able to recognize your Domain! \n \nHave you set the right DNS settings, or multiple Domains directing to the server IP? \n \nPlease enter it manually!"
    while true
    do
        MYDOMAIN=$(dialog --clear \
                          --backtitle "$BACKTITLE" \
                          --inputbox "Enter your Domain without http:// (exmaple.org):" \
                          $HEIGHT $WIDTH \
                          3>&1 1>&2 2>&3 3>&- \
                          )
        if [[ "$MYDOMAIN" =~ $CHECK_DOMAIN ]];then
            break
        else
            dialog_msg "[ERROR] Should we again practice how a Domain address looks?"
            dialog --clear
        fi
    done
fi

# --- DNS Check ---
server_ip=$(ip route get 1.1.1.1 | awk '/1.1.1.1/ {print $(NF-2)}')
sed_replace_word "server_ip" "$server_ip" "/root/NeXt-Server-Lite/dns_settings.txt"
sed_replace_word "yourdomain.com" "$MYDOMAIN" "/root/NeXt-Server-Lite/dns_settings.txt"
dialog --title "DNS Settings" --tab-correct --exit-label "ok" --textbox /root/NeXt-Server-Lite/dns_settings.txt 50 200

BACKTITLE="NeXt Server Installation"
TITLE="NeXt Server Installation"
HEIGHT=15
WIDTH=70

CHOICE_HEIGHT=2
MENU="Have you set the DNS Settings 24-48 hours before running this Script?:"
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
    ;;
2)
    dialog_msg "Sorry, you have to wait 24 - 48 hours, until the DNS system knows your settings!"
    exit
    ;;
esac

setipaddrvars
if [[ ${FQDNIP} != ${IPADR} ]]; then
    echo "${MYDOMAIN} (${FQDNIP}) does not resolve to the IP address of your server (${IPADR})"
    exit
fi

if [ ${CHECKRDNS} != mail.${MYDOMAIN} ] | [ ${CHECKRDNS} != mail.${MYDOMAIN}. ]; then
    echo "Your reverse DNS (${CHECKRDNS}) does not match the SMTP Banner. Please set your Reverse DNS to mail.$MYDOMAIN"
    exit
fi

# --- IP Adress ---
CHOICE_HEIGHT=3
MENU="What IP Mode do you want to use?:"
OPTIONS=(1 "IPv4 only (Standard)" 
         2 "Ipv4 and IPv6 dual stack"
         3 "IPv6 only")
menu
clear
case $CHOICE in
1)
    IPV4_ONLY="1"
    IP_DUAL="0"
    IPV6_ONLY="0"
;;
2)
    IPV4_ONLY="0"
    IP_DUAL="1"
    IPV6_ONLY="0"
;;
3)
    IPV4_ONLY="0"
    IP_DUAL="0"
    IPV6_ONLY="1"
;;
esac

if [[ ${IPV6_ONLY} == '1' ]] || [[ ${IP_DUAL} == '1' ]]; then
    IPV6ADRINPUT=$(dialog --clear \
                          --backtitle "$BACKTITLE" \
                          --inputbox "Enter your IPv6 Address: (Example: 2a03:4000:2:11c5::1)" \
                          $HEIGHT $WIDTH \
                          3>&1 1>&2 2>&3 3>&- \
                          )

    IPV6NETINPUT=$(dialog --clear \
                          --backtitle "$BACKTITLE" \
                          --inputbox "Enter your IPv6 Netmask: (Example: 64)" \
                          $HEIGHT $WIDTH \
                          3>&1 1>&2 2>&3 3>&- \
                          )
fi

PHPVERSION8="8.2"
NXT_SYSTEM_EMAIL="admin@${MYDOMAIN}"
IPV6NETINPUT="fe80::1"
CONFIG_COMPLETED="1"

GIT_LOCAL_FILES_HEAD=$(git rev-parse --short HEAD)
rm -rf /root/NeXt-Server-Lite/configs/userconfig.cfg
cat >> /root/NeXt-Server-Lite/configs/userconfig.cfg <<END
#-----------------------------------------------------------#
############### Config File from Confighelper ###############
#-----------------------------------------------------------#
# This file was created on ${CURRENT_DATE} with NeXt Server Version ${GIT_LOCAL_FILES_HEAD}

CONFIG_COMPLETED="${CONFIG_COMPLETED}"
MYDOMAIN="${MYDOMAIN}"
PHPVERSION8="${PHPVERSION8}"
IP6ADR="${IPV6ADRINPUT}"
IPV6GAT="${IPV6GATINPUT}"
IPV6NET="${IPV6NETINPUT}"
IPV4_ONLY="${IPV4_ONLY}"
IP_DUAL="${IP_DUAL}"
IPV6_ONLY="${IPV6_ONLY}"
HPKP1="1"
HPKP2="2"

NXT_SYSTEM_EMAIL="${NXT_SYSTEM_EMAIL}"
NXT_IS_INSTALLED="0"
NXT_INSTALL_DATE="0"
NXT_INSTALL_TIME_SECONDS="0"

NEXTCLOUD_IS_INSTALLED="0"
WORDPRESS_IS_INSTALLED="0"
PMA_IS_INSTALLED="0"
MUNIN_IS_INSTALLED="0"
COMPOSER_IS_INSTALLED="0"

NEXTCLOUD_PATH_NAME="0"
WORDPRESS_PATH_NAME="0"
PHPMYADMIN_PATH_NAME="0"
MUNIN_PATH_NAME="0"
MYSQL_HOSTNAME="localhost"
TIMEZONE="EMPTY_TIMEZONE"

#-----------------------------------------------------------#
############### Config File from Confighelper ###############
#-----------------------------------------------------------#
END

dialog --title "Userconfig" --exit-label "ok" --textbox /root/NeXt-Server-Lite/configs/userconfig.cfg 50 250
clear

CHOICE_HEIGHT=2
MENU="Settings correct?"
OPTIONS=(1 "Yes"
         2 "No")
menu
clear
case $CHOICE in
1)
    #continue
;;
2)
    confighelper_userconfig
;;
esac
}