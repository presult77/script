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
	read -rp "Input Username : " user
    read -p "Expired (days): " masaaktif

    CLIENT_EXISTS=$(grep -w $user /etc/xray/vless.json | wc -l)
	if [[ ${CLIENT_EXISTS} == '0' ]]; then
		exit
	fi

    exp=$(grep -wE "^#& $user" "/etc/xray/vless.json" | cut -d ' ' -f 3 | sort | uniq)
    now=$(date +%Y-%m-%d)
    d1=$(date -d "$exp" +%s)
    d2=$(date -d "$now" +%s)
    exp2=$(( (d1 - d2) / 86400 ))
    exp3=$(($exp2 + $masaaktif))
    exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
    sed -i "/#& $user/c\#& $user $exp4" /etc/xray/vless.json
    
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
    at now -f /root/restart-vless.sh
