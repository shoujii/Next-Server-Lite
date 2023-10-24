#!/bin/bash

check_php() {

#check version
command=$(php -v)
phpv=$(echo $command | cut -c4-7)

if [ $phpv != ${PHPVERSION8} ]; then
  echo "${error} The installed PHP Version $phpv is DIFFERENT with the PHP Version ${PHPVERSION8} defined in the Userconfig!"
else
	echo "${ok} The PHP Version $phpv is equal with the PHP Version ${PHPVERSION8} defined in the Userconfig!"
fi

check_service "php$PHPVERSION8-fpm"
echo ""
}
