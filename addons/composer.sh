#!/bin/bash

install_composer() {

trap error_exit ERR

cd /root/NeXt-Server-Bookworm/sources/

EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
then
    >&2 echo 'ERROR: Invalid installer signature'
    rm composer-setup.php
    exit
fi

php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer

sed_replace_word "COMPOSER_IS_INSTALLED=\"0"\" "COMPOSER_IS_INSTALLED=\"1"\" "/root/NeXt-Server-Bookworm/configs/userconfig.cfg"
}