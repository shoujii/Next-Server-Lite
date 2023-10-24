#!/bin/bash

update_firewall() {

trap error_exit ERR

apt update
}