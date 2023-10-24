#!/bin/bash

update_libressl() {

trap error_exit ERR

source /root/NeXt-Server-Lite/configs/sources.cfg

LOCAL_LIBRESSL_VERSION=$(openssl version | awk '/LibreSSL/ {print $(NF-0)}')

if [[ ${LOCAL_LIBRESSL_VERSION} != ${LIBRESSL_VERSION} ]]; then
    cd /root/NeXt-Server-Lite/sources
    wget https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LIBRESSL_VERSION}.tar.gz
    tar -xzf libressl-${LIBRESSL_VERSION}.tar.gz
    cd libressl-${LIBRESSL_VERSION}
    ./configure
    make install -j $(nproc) >>"${make_log}" 2>>"${make_err_log}"
fi
}