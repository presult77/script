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
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/xray/vmess.json")
total=$(($NUMBER_OF_CLIENTS / 2))
	if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
		echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo -e "\E[44;1;39m     ⇱ Delete Vmess Account ⇲     \E[0m"
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━\033[0m"
		echo ""
		echo "You have no existing clients!"
		echo ""
		echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━\033[0m"
		exit
	fi
	clear
	echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m     ⇱ Delete Vmess Account ⇲     \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo "  User       Expired  " 
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━\033[0m"
	grep -E "^### " "/etc/xray/vmess.json" | cut -d ' ' -f 2-3 | column -t | sort | uniq
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m Total Vmess User: $total \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━\033[0m"
	read -rp "Input Username : " user
    CLIENT_EXISTS=$(grep -w $user /etc/xray/vmess.json | wc -l)
    if [[ ${CLIENT_EXISTS} == '0' ]]; then
    exit 1
	else
	exp=$(grep -E "^### $user" "/etc/xray/vmess.json" | cut -d ' ' -f 3 | sort | uniq)
	sed -i "/^### $user $exp/,/^},{/d" /etc/xray/vmess.json
	rm -f /etc/xray/vmess-$user-tls.json /etc/xray/vmess-$user-nontls.json
	clear
	echo ""
	echo "==============================="
	echo "  Xray/Vmess Account Deleted  "
	echo "==============================="
	echo "Username  : $user"
	echo "Expired   : $exp"
	echo "==============================="
	echo "Regards"
	sleep 1
	at now -f /root/restart-vmess.sh
	fi
