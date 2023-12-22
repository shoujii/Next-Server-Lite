#!/bin/bash

password() {
  while true; do
    random_password=$(openssl rand -base64 40 | tr -d / | cut -c -32 | grep -P '(?=^.{8,255}$)(?=^[^\s]*$)(?=.*\d)(?=.*[A-Z])(?=.*[a-z])')

      if [ -z "$random_password" ]
      then
            echo "empty" > /dev/null 2>&1
      else
            echo "$random_password"
            break
      fi
  done
}

username() {
  while true; do
  random_username=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 24 | head -n 1)
    if [ -z "$random_username" ]
    then
          echo "empty" > /dev/null 2>&1
    else
          echo "$random_username"
          break;
    fi
done
}

sed_replace_word() {
  var_1_clean=$(echo "$1" | sed 's/\//\\\//g')
  var_2_clean=$(echo "$2" | sed 's/\//\\\//g')
  sed -i "s/$var_1_clean/$var_2_clean/g" $3 
}

setipaddrvars() {
IPADR=$(ip route get 1.1.1.1 | awk '/1.1.1.1/ {print $(NF-2)}')
IPV4GAT=$(ip route | awk '/default/ { print $3 }')
INTERFACE=$(ip route get 1.1.1.1 | head -1 | cut -d' ' -f5)
FQDNIP=$(dig @1.1.1.1 +short ${MYDOMAIN})
WWWIP=$(dig @1.1.1.1 +short www.${MYDOMAIN})
CHECKRDNS=$(dig @1.1.1.1 -x ${IPADR} +short)
}

get_domain() {
  #
  ### need case for Ipv6 only server ###
  #
  LOCAL_IP=$(hostname -I | awk '{print $1;}') 
  POSSIBLE_DOMAIN=$(dig @1.1.1.1 -x ${LOCAL_IP} +short)
  DETECTED_DOMAIN=$(echo "${POSSIBLE_DOMAIN}" | awk -v FS='.' '{print $2 "." $3}')
}

menu() {
CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --no-cancel \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)
}

function dialog_info() {
dialog --backtitle "NeXt Server Installation" --infobox "$1" 40 80
}

function dialog_msg() {
dialog --backtitle "NeXt Server Installation" --msgbox "$1" 40 80
}

function dialog_yesno_configuration() {
dialog --backtitle "NeXt Server Installation" \
--yesno "Continue with NeXt Server Configuration?" 7 60

CHOICE=$?
case $CHOICE in
   1)
        echo "Skipped the NeXt Server Configuration!"
        exit;;
esac
}

CHECK_E_MAIL="^[a-zA-Z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-zA-Z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?\$"
CHECK_PASSWORD="^[A-Za-z0-9]*$"
####not perfectly working!!!!
CHECK_DOMAIN="^[a-zA-Z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-zA-Z0-9!#$%&'*+/=?^_\`{|}~-]+)*.([a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z])?\$"
CURRENT_DATE=`date +%Y-%m-%d:%H:%M:%S`

function check_service() {
if systemctl is-failed --quiet $1
then
    echo "${error} $1 is not running!"
else
    echo "${ok} $1 is running!"
fi
}

function wget_tar() {
wget --no-check-certificate $1 --tries=3 
        ERROR=$?
        if [[ "$ERROR" != '0' ]]; then
      echo "Error: $1 download failed."
      exit
    fi
}

function tar_file() {
tar -xzf $1 
        ERROR=$?
        if [[ "$ERROR" != '0' ]]; then
      echo "Error: $1 is corrupted."
      exit
    fi
rm $1
}

function unzip_file() {
unzip $1 
	ERROR=$?
	if [[ "$ERROR" != '0' ]]; then
      echo "Error: $1 is corrupted."
      exit
    fi
}

function install_packages() {
DEBIAN_FRONTEND=noninteractive apt -y install $1
        ERROR=$?
        if [[ "$ERROR" != '0' ]]; then
      echo "Error: $1 had an error $ERROR during installation."
      exit
    fi
}

function remove_packages() {
DEBIAN_FRONTEND=noninteractive apt -y remove $1
        ERROR=$?
        if [[ "$ERROR" != '0' ]]; then
      echo "Error: $1 had an error $ERROR during removing."
      exit
    fi
}

error_exit() {
  #clear
  read line file <<<$(caller)
  echo "An error occurred in line $line of file $file:" >&2
  sed "${line}q;d" "$file" >&2
  echo ""
  USED_OS=$(lsb_release -ic)
  echo "Your used OS is: $USED_OS"
  echo ""
  echo "If you don't know how to resolve this Issue, please visit https://github.com/shoujii/NeXt-Server-Lite/issues/new to add the Issue on Github!"
  exit
}

show_login_information() {
  dialog_msg "Please save the shown login information on next page"
  cat /root/NeXt-Server-Lite/login_information.txt
}

continue_to_menu() {
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit
  fi
  bash /root/NeXt-Server-Lite/nxt.sh
}

continue_or_exit() {
  read -p "Continue (y/n)?" ANSW
  if [ "$ANSW" = "n" ]; then
  echo "Exit"
  exit
  fi
}

greenb() { 
  echo $(tput bold)$(tput setaf 2)${1}$(tput sgr0); 
}
ok="$(greenb [OKAY] -)"

redb() { 
  echo $(tput bold)$(tput setaf 1)${1}$(tput sgr0); 
}
error="$(redb [ERROR] -)"

progress_gauge() {
  echo "$1" | dialog --gauge "$2" 10 70 0
}

kernel_check_failed() {
LOCAL_KERNEL_VERSION=$(uname -a | awk '/Linux/ {print $(NF-7)}') 
BACKTITLE="NeXt Server Installation"
TITLE="NeXt Server Installation"
HEIGHT=15
WIDTH=70

CHOICE_HEIGHT=2
MENU="The script wasn't able to verify your kernel version(${LOCAL_KERNEL_VERSION})\nThe script needs kernel version ${KERNEL_VERSION} to run properly\nDo you want to continue?"
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
#continue
;;

2)
exit
;;
esac
}