#!/bin/bash

menu_options_openssh() {

source /root/NeXt-Server-Lite/configs/sources.cfg

HEIGHT=40
WIDTH=80
CHOICE_HEIGHT=5
BACKTITLE="NeXt Server"
TITLE="NeXt Server"
MENU="Choose one of the following options:"

OPTIONS=(1 "Add new Openssh User"
         2 "Change Openssh Port"
         3 "Create new Openssh Key"
         4 "Back"
         5 "Exit")

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
NEW_OPENSSH_USER=$(dialog --clear \
                          --backtitle "$BACKTITLE" \
                          --inputbox "Please enter the new Openssh Username:" \
                          $HEIGHT $WIDTH \
                          3>&1 1>&2 2>&3 3>&- \
                          )
add_openssh_user
dialog_msg "Finished adding Openssh User"
continue_or_exit
menu_options_openssh
;;

2)
while true
do
INPUT_NEW_SSH_PORT=$(dialog --clear \
                            --backtitle "$BACKTITLE" \
                            --inputbox "Enter your SSH Port (only max. 3 numbers!):" \
                            $HEIGHT $WIDTH \
                            3>&1 1>&2 2>&3 3>&- \
                            )
if [[ $INPUT_NEW_SSH_PORT =~ ^-?[0-9]+$ ]]; then
    if [ ${#INPUT_NEW_SSH_PORT} -ge 4 ]; then
       dialog_msg "Your Input has more than 3 numbers, please try again"
       dialog --clear
    else
        array=($(cat "/root/NeXt-Server-Lite/configs/blocked_ports.conf"))
        printf -v array_str -- ',,%q' "${array[@]}"
        while true
        do
            if [[ "${array_str},," =~ ,,${INPUT_NEW_SSH_PORT},, ]]; then
                dialog_msg "$INPUT_NEW_SSH_PORT is known. Choose an other Port!"
                dialog --clear
            else
                NEW_SSH_PORT="$INPUT_NEW_SSH_PORT"
                sed_replace_word "^Port .*" "Port $NEW_SSH_PORT" "/etc/ssh/sshd_config"
                break
            fi
        done
        echo "#------------------------------------------------------------------------------#" >> /root/NeXt-Server-Lite/login_information.txt
        echo "#Date of change $(date +"%d-%m-%Y_%H_%M_%S")" >> /root/NeXt-Server-Lite/login_information.txt
        echo "#NEW_SSH_PORT: $NEW_SSH_PORT" >> /root/NeXt-Server-Lite/login_information.txt
        echo "#------------------------------------------------------------------------------#" >> /root/NeXt-Server-Lite/login_information.txt
        echo "" >> /root/NeXt-Server-Lite/login_information.txt
        systemctl -q restart ssh
        break
    fi
else
    dialog_msg "The Port should only contain numbers!"
    dialog --clear
fi
done
dialog_msg "Changed SSH Port to $NEW_SSH_PORT"
continue_or_exit
menu_options_openssh
;;

3)
dialog_info "Creating new Openssh key"
create_new_openssh_key
dialog_msg "Finished creating new ssh key"
echo
echo
echo "You can find your New SSH key at /root/NeXt-Server-Lite/ssh_privatekey.txt"
echo
echo
echo "Password for your new ssh key = $NEW_SSH_PASS"
echo
echo
echo "Your new SSH Key"
cat /root/NeXt-Server-Lite/ssh_privatekey.txt
continue_or_exit
menu_options_openssh
;;

4)
menu_options_services
;;

5)
echo "Exit"
exit 1
;;
esac
}