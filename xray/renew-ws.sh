#!/bin/bash
# ━━━━━━━━━━━━━━━━━━━━━===========
# Color
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
# ━━━━━━━━━━━━━━━━━━━━━===========
# Getting
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
#########################

MYIP=$(curl -sS ipv4.icanhazip.com)
clear
	read -rp "Input Username : " user
    read -p "Expired (days): " masaaktif

	CLIENT_EXISTS=$(grep -w $user /etc/xray/config.json | wc -l)
	if [[ ${CLIENT_EXISTS} == '0' ]]; then
		exit
	fi
	
    exp=$(grep -E "^### $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
    now=$(date +%Y-%m-%d)
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(( (d1 - d2) / 86400 ))
    exp3=$(($exp2 + $masaaktif))
    exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
	sed -i "s/### $user $exp/### $user $exp4/g" /etc/xray/config.json
	sed -i "s/### $user $exp/### $user $exp4/g" /etc/xray/config.json

	clear
	echo "" | tee -a /etc/log-create-user.log
	echo "━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
	echo "  Xray/Vmess Account Renewed  " | tee -a /etc/log-create-user.log
	echo "━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
	echo "Username  : $user" | tee -a /etc/log-create-user.log
	echo "Expired   : $exp4" | tee -a /etc/log-create-user.log
	echo "━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
	echo "THANKS FOR USING OUR SERVICE" | tee -a /etc/log-create-user.log

	sleep 1
	service cron restart
	systemctl restart xray > /dev/null 2>&1
