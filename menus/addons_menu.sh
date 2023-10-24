#!/bin/bash

menu_options_addons() {

source /root/NeXt-Server-Lite/configs/sources.cfg
set_logs

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=9
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

OPTIONS=(1 "Install Nextcloud"
         2 "Deinstall Nextcloud"
         3 "Install phpmyadmin"
         4 "Deinstall phpmyadmin"
         5 "Install Munin"
         6 "Install Wordpress"
         7 "Deinstall Wordpress"
         8 "Back"
         9 "Exit")

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
if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
    if [[ ${NEXTCLOUD_IS_INSTALLED} == '1' ]]; then
        echo "Nextcloud is already installed!"
    else
        menu_options_nextcloud
        install_nextcloud
        dialog --title "Your Nextcloud logininformations" --tab-correct --exit-label "ok" --textbox /root/NeXt-Server-Lite/nextcloud_login_data.txt 50 200
    fi
else
    echo "You have to install the NeXt Server with the Webserver component to run this Addon!"
fi
continue_or_exit
menu_options_addons
;;

2)
if [[ ${NEXTCLOUD_IS_INSTALLED} == '0' ]]; then
    echo "Nextcloud is already deinstalled!"
else
    dialog_info "Deinstalling Nextcloud"
    deinstall_nextcloud
    dialog_msg "Finished Deinstalling Nextcloud"
fi
continue_or_exit
menu_options_addons
;;

3)
if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
    if [[ ${PMA_IS_INSTALLED} == '1' ]]; then
        echo "Phpmyadmin is already installed!"
    else
        menu_options_phpmyadmin
        if [[ ${COMPOSER_IS_INSTALLED} == '0' ]]; then
            install_composer
        fi
        install_phpmyadmin
        dialog_msg "Finished installing PHPmyadmin"
    fi
else
    echo "You have to install the NeXt Server with the Webserver component to run this Addon!"
fi
continue_or_exit
menu_options_addons
;;

4)
if [[ ${PMA_IS_INSTALLED} == '0' ]]; then
    echo "Phpmyadmin is already deinstalled!"
else
    dialog_info "Deinstalling PHPmyadmin"
    deinstall_phpmyadmin
    dialog_msg "Finished Deinstalling PHPmyadmin"
fi
continue_or_exit
menu_options_addons
;;

5)
if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
    if [[ ${MUNIN_IS_INSTALLED} == '1' ]]; then
        echo "Munin is already installed!"
    else
        dialog_info "Installing Munin"
        menu_options_munin
        install_munin
        dialog_msg "Finished installing Munin"
    fi
else
    echo "You have to install the NeXt Server with the Webserver component to run this Addon!"
fi
continue_or_exit
menu_options_addons
;;

6)
if [[ ${NXT_IS_INSTALLED} == '1' ]] || [[ ${NXT_IS_INSTALLED_MAILSERVER} == '1' ]]; then
    if [[ ${WORDPRESS_IS_INSTALLED} == '1' ]]; then
        echo "Wordpress is already installed!"
    else
        menu_options_wordpress
        install_wordpress
        if [ "${WORDPRESS_PATH_NAME}" != "root" ]; then
           dialog_msg "Visit ${MYDOMAIN}/${WORDPRESS_PATH_NAME} to finish the installation"
        else
           dialog_msg "Visit ${MYDOMAIN}/ to finish the installation"
        fi
    fi
else
    echo "You have to install the NeXt Server with the Webserver component to run this Addon!"
fi
continue_or_exit
menu_options_addons
;;

7)
if [[ ${WORDPRESS_IS_INSTALLED} == '0' ]]; then
    echo "Wordpress is already deinstalled!"
else
    dialog_info "Deinstalling Wordpress"
    deinstall_wordpress
    dialog_msg "Finished Deinstalling Wordpress"
fi
continue_or_exit
menu_options_addons
;;

8)
bash /root/NeXt-Server-Lite/nxt.sh
;;

9)
echo "Exit"
exit 1
;;
esac
}