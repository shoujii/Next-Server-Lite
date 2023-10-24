#!/bin/bash

menu_options_services() {

source /root/NeXt-Server-Lite/configs/sources.cfg
set_logs

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=4
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

OPTIONS=(1 "Openssh Options"
         2 "Firewall Options"
         3 "Back"
         4 "Exit")

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
menu_options_openssh
;;

2)
menu_options_firewall
;;

3)
bash /root/NeXt-Server-Lite/nxt.sh
;;

4)
echo "Exit"
exit
;;
esac
}