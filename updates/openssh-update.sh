#!/bin/bash

update_openssh() {

trap error_exit ERR

source /root/NeXt-Server-Bookworm/configs/sources.cfg

LOCAL_OPENSSH_VERSION=$(ssh -V 2>&1 | awk '/OpenSSH/ {print $(NF-6)}')
OPENSSH_VERSION="OpenSSH_${OPENSSH_VERSION}"

if [[ ${LOCAL_OPENSSH_VERSION} != ${OPENSSH_VERSION} ]]; then
    apt update >/dev/null 2>&1
    apt -y upgrade >/dev/null 2>&1
fi
}