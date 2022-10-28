#!/bin/bash
# ==========================================
# Color
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
# ==========================================
# Getting
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
#########################

MYIP=$(curl -sS ipv4.icanhazip.com)
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/xray/config.json")
	if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
		clear
		exit
	fi

	read -rp "Input Username : " user
    if [ -z $user ]; then
    exit
    else
    read -p "Expired (days): " masaaktif
    exp=$(grep -wE "^#& $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
    now=$(date +%Y-%m-%d)
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(( (d1 - d2) / 86400 ))
    exp3=$(($exp2 + $masaaktif))
    exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
    sed -i "/#& $user/c\#& $user $exp4" /etc/xray/config.json


clear
echo ""
echo "==============================="
echo "  Xray/Vmess Account Renewed  "
echo "==============================="
echo "Username  : $user"
echo "Expired   : $exp4"
echo "==============================="
echo "THANKS FOR USING OUR SERVICE"
	sleep 1
	service cron restart
	systemctl restart xray > /dev/null 2>&1
    fi
