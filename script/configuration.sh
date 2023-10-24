#!/bin/bash

start_after_install() {

  trap error_exit ERR

  source /root/NeXt-Server-Bookworm/configs/sources.cfg

  check_nginx && continue_or_exit
  check_php && continue_or_exit
  check_openssh && continue_or_exit
  check_fail2ban && continue_or_exit
  check_lets_encrypt && continue_or_exit
  check_firewall && continue_or_exit
  check_system && continue_or_exit
  show_ssh_key && continue_or_exit

  dialog_msg "Please save the shown login information on next page"
  cat /root/NeXt-Server-Bookworm/login_information.txt && continue_or_exit

  create_private_key

  dialog_msg "Finished configuration! \n\n
  Please do -> never <- delete any login information stored in the .txt files!"
}