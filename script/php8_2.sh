#!/bin/bash

install_php_8_2() {

trap error_exit ERR

PHPVERSION8="8.2"

install_packages "php$PHPVERSION8-dev php$PHPVERSION8-fpm php$PHPVERSION8-gmp php$PHPVERSION8-Pspell php$PHPVERSION8-bz2 php-auth-sasl php$PHPVERSION8-gd php$PHPVERSION8-bcmath php$PHPVERSION8-zip php-mail php-net-dime php-net-url php-pear php-apcu php$PHPVERSION8 php$PHPVERSION8-cli php$PHPVERSION8-common php$PHPVERSION8-curl php$PHPVERSION8-fpm php$PHPVERSION8-intl php$PHPVERSION8-mysql php$PHPVERSION8-soap php$PHPVERSION8-sqlite3 php$PHPVERSION8-xsl php-mbstring php-xml php$PHPVERSION8-opcache php$PHPVERSION8-readline php$PHPVERSION8-xml php$PHPVERSION8-mbstring php-memcached php-imagick"

sed_replace_word "memory_limit = 128M" "memory_limit = 512M" "/etc/php/$PHPVERSION8/fpm/php.ini"
sed_replace_word "upload_max_filesize = 2M" "upload_max_filesize = 512M" "/etc/php/$PHPVERSION8/fpm/php.ini"
sed_replace_word ";cgi.fix_pathinfo=1" "cgi.fix_pathinfo=1" "/etc/php/$PHPVERSION8/fpm/php.ini"

#uncomment various env -> Nextcloud
sed_replace_word ";env\[HOSTNAME\] = \$HOSTNAME" "env[HOSTNAME] = \$HOSTNAME" "/etc/php/$PHPVERSION8/fpm/pool.d/www.conf"
sed_replace_word ";env\[PATH] = /usr/local/bin:/usr/bin:/bin" "env\[PATH] = /usr/local/bin:/usr/bin:/bin" "/etc/php/$PHPVERSION8/fpm/pool.d/www.conf"
sed_replace_word ";env\[TMP] = /tmp" "env\[TMP] = /tmp" "/etc/php/$PHPVERSION8/fpm/pool.d/www.conf"
sed_replace_word ";env\[TMPDIR] = /tmp" "env\[TMPDIR] = /tmp" "/etc/php/$PHPVERSION8/fpm/pool.d/www.conf"
sed_replace_word ";env\[TEMP] = /tmp" "env\[TEMP] = /tmp" "/etc/php/$PHPVERSION8/fpm/pool.d/www.conf"

systemctl -q restart nginx.service
systemctl -q restart php$PHPVERSION8-fpm.service
}