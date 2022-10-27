#!/bin/bash
# My Telegram : https://t.me/IzhanV
# ==========================================
#########################
MYIP=$(curl -sS ipv4.icanhazip.com)
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/rare/xray/grpc/akuntrgrpc.conf")
	if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
		clear
		echo ""
		echo "You have no existing clients!"
		exit 1
	fi

	clear
	echo ""
	echo "Select the existing client you want to renew"
	echo " Press CTRL+C to return"
	echo -e "==============================="
	grep -E "^### " "/etc/rare/xray/grpc/akuntrgrpc.conf" | cut -d ' ' -f 2-3 | nl -s ') '
	until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
		if [[ ${CLIENT_NUMBER} == '1' ]]; then
			read -rp "Select one client [1]: " CLIENT_NUMBER
		else
			read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
		fi
	done
read -p "Expired (Days) : " masaaktif
user=$(grep -E "^### " "/etc/rare/xray/grpc/akuntrgrpc.conf" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/etc/rare/xray/grpc/akuntrgrpc.conf" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
exp3=$(($exp2 + $masaaktif))
exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
sed -i "^### $user $exp/,/^},{/d" /etc/rare/xray/grpc/akuntrgrpc.conf
sed -i "^### $user $exp/,/^},{/d" /etc/rare/xray/grpc/trojangrpc.json

clear
echo ""
echo "================================"
echo "  Xray/Trojan Account Renewed  "
echo "================================"
echo "Username  : $user"
echo "Expired  : $exp4"
echo "================================"
echo ""
echo "================================"
echo "Script By izhanworks"
echo "================================"
read -p "Press Enter For Back To TRojan Menu/ CTRL+C To Cancel : "
renewtrgrpc
