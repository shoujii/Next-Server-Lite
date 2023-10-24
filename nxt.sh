#!/bin/bash

clear
echo "NeXt Server"
echo "Preparing menu..."

if [ $(dpkg-query -l | grep dialog | wc -l) -ne 3 ]; then
    apt -qq install dialog >/dev/null 2>&1
fi

source /root/NeXt-Server-Lite/configs/sources.cfg

dev_mode=/root/NeXt-Server-Lite/dev.conf
if [ -f "$dev_mode" ]; then
    sed_replace_word "ec-384" "ec-384 --staging" "/root/NeXt-Server-Lite/script/lets_encrypt.sh"
    sed_replace_word "1.1.1.1" "46.38.225.230" "/root/NeXt-Server-Lite/script/functions.sh"
    sed -i '100,109 s/^/#/' /root/NeXt-Server-Lite/confighelper.sh
    sed -i '17,18 s/^/#/' /root/NeXt-Server-Lite/script/checksystem.sh
    set -x
fi

GIT_LOCAL_FILES_HEAD=$(git rev-parse --short HEAD)
GIT_LOCAL_FILES_HEAD_LAST_COMMIT=$(git log -1 --date=short --pretty=format:%cd)

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=8
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="\n Choose one of the following options: \n \n"

OPTIONS=(1 "Install NeXt Server Version: ${GIT_LOCAL_FILES_HEAD} - ${GIT_LOCAL_FILES_HEAD_LAST_COMMIT}"
         2 "After Installation configuration"
         3 "Update NeXt Server Installation"
         4 "Update NeXt Server Script Code Base"
         5 "Services Options"
         6 "Addon Installation"
         7 "Update Let's encrypt certificate"
         8 "Exit")

CHOICE=$(dialog --clear \
                --nocancel \
                --no-cancel \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
1)
if [[ ${NXT_IS_INSTALLED} == '1' ]]; then
    echo "The NeXt-Server Script is already installed!"
    continue_to_menu
else
    bash install.sh
fi
;;

2)
if [[ ${NXT_IS_INSTALLED} == '1' ]]; then
    menu_options_after_install
else
    echo "Please install the NeXt-Server Script before starting the configuration!"
    continue_to_menu
fi
;;

3)
if [[ ${NXT_IS_INSTALLED} == '1' ]]; then
    update_all_services
else
    echo "You have to install the NeXt Server to run the services update!"
    continue_to_menu
fi
;;

4)
dialog_info "Updating NeXt Server Script"
update_script
bash nxt.sh
;;

5)
if [[ ${NXT_IS_INSTALLED} == '1' ]]; then
    menu_options_services
else
    echo "You have to install the NeXt Server to run the services options!"
    continue_to_menu
fi
;;

6)
if [[ ${NXT_IS_INSTALLED} == '1' ]]; then
    menu_options_addons
else
    echo "You have to install the NeXt Server to install addons!"
    continue_to_menu
fi
;;

7)
if [[ ${NXT_IS_INSTALLED} == '1' ]]; then
        update_nginx_cert
        echo "Updated your Let's Encrypt Certificate!"
    fi
else
    echo "You have to install the NeXt Server to update  Let's Encrypt Certificate!"
    continue_to_menu
fi
;;

8)
echo "Exit"
exit
;;
esac