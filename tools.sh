#!/bin/bash
clear
NET=$(ip -o -4 route show to default | awk '{print $5}');
red='\e[1;31m'
green='\e[1;32m'
yell='\e[1;33m'
NC='\e[0m'
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }

if [[ -e /etc/debian_version ]]; then
	source /etc/os-release
	OS=$ID # debian or ubuntu
elif [[ -e /etc/centos-release ]]; then
	source /etc/os-release
	OS=centos
fi

echo "Tools install...!"
echo "Progress..."
sleep 2

sudo apt update -y
sudo apt update -y
sudo apt dist-upgrade -y
sudo apt-get remove --purge exim4 -y 

sudo apt install -y screen curl gzip coreutils rsyslog iftop \
 htop zip unzip net-tools sed \
 sudo build-essential lsof \
 openssl easy-rsa fail2ban tmux \
 dbus vnstat socat\

fi

yellow() { echo -e "\\033[33;1m${*}\\033[0m"; }
yellow "Dependencies successfully installed..."
sleep 3
clear
