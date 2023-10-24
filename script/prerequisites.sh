#!/bin/bash

prerequisites() {

trap error_exit ERR

install_packages "build-essential dbus libcrack2 dnsutils netcat-openbsd automake autoconf gawk lsb-release"
}