#!/bin/bash

menu_options_after_install() {

source /root/NeXt-Server-Lite/configs/sources.cfg

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=6
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

OPTIONS=(1 "Full after installation configuration"
         2 "Show SSH Key"
         3 "Show Login information"
         4 "Create private key"
         5 "Back"
         6 "Exit")

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
  start_after_install && continue_to_menu
;;

2)
  show_ssh_key && continue_to_menu
;;

3)
  show_login_information && continue_to_menu
;;

4)
  create_private_key && continue_to_menu
;;

5)
  bash /root/NeXt-Server-Lite/nxt.sh
;;

6)
  echo "Exit"
  exit
;;

esac
}