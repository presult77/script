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
	read -p "Expired (Days) : " masaaktif

    CLIENT_EXISTS=$(grep -w $user /etc/trojan-go/akun.conf | wc -l)
	if [[ ${CLIENT_EXISTS} == '0' ]]; then
		exit
	fi	

exp=$(grep -E "^### $user" "/etc/trojan-go/akun.conf" | cut -d ' ' -f 3 | sort | uniq)
now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
exp3=$(($exp2 + $masaaktif))
exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
sed -i "s/### $user $exp/### $user $exp4/g" /etc/trojan-go/akun.conf
clear
echo ""
echo "============================"
echo "  TrojanGo Account Renewed  "
echo "============================"
echo "Username : $user"
echo "Expired  : $exp4"
echo "=========================="
echo "THANKS FOR USING OUR SERVICE"
