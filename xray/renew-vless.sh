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

clear

NUMBER_OF_CLIENTS=$(grep -c -E "^#& " "/etc/xray/config.json")
	if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
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
    echo -e "━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
    echo "VLESS Account Was Successfully Renewed" | tee -a /etc/log-create-user.log
    echo -e "━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
    echo ""
    echo " Client Name : $user" | tee -a /etc/log-create-user.log
    echo " Expired On  : $exp4" | tee -a /etc/log-create-user.log
    echo "" | tee -a /etc/log-create-user.log
    echo "THANKS FOR USING OUR SERVICE" | tee -a /etc/log-create-user.log
    echo -e "━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
    echo "" | tee -a /etc/log-create-user.log
    sleep 1
    systemctl restart xray > /dev/null 2>&1
    fi
