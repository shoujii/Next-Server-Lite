#!/bin/bash

install_libressl() {

trap error_exit ERR

install_packages "libtool perl"

cd /root/NeXt-Server-Lite/sources
##change to functions
wget https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LIBRESSL_VERSION}.tar.gz
tar -xzf libressl-${LIBRESSL_VERSION}.tar.gz
cd libressl-${LIBRESSL_VERSION}
./configure
make install -j $(nproc) >>"${make_log}" 2>>"${make_err_log}"
}