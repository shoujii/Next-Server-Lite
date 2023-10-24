#!/bin/bash

add_openssh_user() {

trap error_exit ERR

apt update
#usermod -a -G ssh-user root
}

create_new_openssh_key() {

trap error_exit ERR

rm -rf ~/.ssh/*
rm /root/NeXt-Server-Bookworm/ssh_privatekey.txt

NEW_SSH_PASS=$(password)
echo "#------------------------------------------------------------------------------#" >> /root/NeXt-Server-Bookworm/login_information.txt
echo "#NEW_SSH_PASS: $NEW_SSH_PASS" >> /root/NeXt-Server-Bookworm/login_information.txt
echo "#------------------------------------------------------------------------------#" >> /root/NeXt-Server-Bookworm/login_information.txt
echo "" >> /root/NeXt-Server-Bookworm/login_information.txt

ssh-keygen -f ~/ssh.key -t ed25519 -N $NEW_SSH_PASS
mkdir -p ~/.ssh && chmod 700 ~/.ssh
cat ~/ssh.key.pub > ~/.ssh/authorized_keys2 && rm ~/ssh.key.pub
chmod 600 ~/.ssh/authorized_keys2
mv ~/ssh.key /root/NeXt-Server-Bookworm/ssh_privatekey.txt

systemctl -q restart ssh
}

show_ssh_key() {

trap error_exit ERR

dialog_msg "Please save the shown SSH privatekey on next page into a textfile on your PC. \n\n
Important: \n
In Putty you have only mark the text. Do not Press STRG+C!"
cat /root/NeXt-Server-Bookworm/ssh_privatekey.txt
}

create_private_key() {
dialog_msg "You have to download the latest PuTTYgen Snapshot! \n (https://www.chiark.greenend.org.uk/~sgtatham/putty/snapshot.html) \n \n
Start the program and click on Conversions- Import key. \n
Now select the Text file, where you saved the ssh_privatekey. \n
After entering your SSH Password, you have to switch the paramter from RSA to ED25519. \n
In the last step click on save private key - done! \n \n
Dont forget to change your SSH Port in PuTTY!"
}