#!/bin/bash
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
#########################
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }

clear

	read -rp "Input Username : " user
    read -p "Expired (days): " masaaktif
    
    CLIENT_EXISTS=$(grep -w $user /etc/xray/config.json | wc -l)
	if [[ ${CLIENT_EXISTS} == '0' ]]; then
		exit
	fi

    exp=$(grep -wE "^#! $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
    now=$(date +%Y-%m-%d)
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(( (d1 - d2) / 86400 ))
    exp3=$(($exp2 + $masaaktif))
    exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
    sed -i "/#! $user/c\#! $user $exp4" /etc/xray/config.json
    clear
    echo -e "━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
    echo "Trojan Account Was Successfully Renewed" | tee -a /etc/log-create-user.log
    echo -e "━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
    echo "" | tee -a /etc/log-create-user.log
    echo " Client Name : $user" | tee -a /etc/log-create-user.log
    echo " Expired On  : $exp4" | tee -a /etc/log-create-user.log
    echo "" | tee -a /etc/log-create-user.log
    echo "THANKS FOR USING OUR SERVICE" | tee -a /etc/log-create-user.log
    echo -e "━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
    echo "" | tee -a /etc/log-create-user.log
    sleep 1
    systemctl restart xray > /dev/null 2>&1
