#!/bin/bash
# SL
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
uuid=$(cat /etc/trojan-go/uuid.txt)
source /var/lib/SIJA/ipvps.conf
if [[ "$IP" = "" ]]; then
domain=$(cat /etc/xray/domain)
else
domain=$IP
fi
trgo="$(cat ~/log-install.txt | grep -w "Trojan Go" | cut -d: -f2|sed 's/ //g')"
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${user_EXISTS} == '0' ]]; do
		read -rp "User : " -e user
		user_EXISTS=$(grep -w $user /etc/trojan-go/akun.conf | wc -l)

		if [[ ${user_EXISTS} == '1' ]]; then
			exit
		fi
	done
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (Days) : " masaaktif
sed -i '/"'""$uuid""'"$/a\,"'""$user""'"' /etc/trojan-go/config.json
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
hariini=`date -d "0 days" +"%Y-%m-%d"`
echo -e "### $user $exp" >> /etc/trojan-go/akun.conf
link="trojan-go://${uuid}@isi_bug_disini:${trgo}/?sni=${domain}&type=ws&host=${domain}&path=%2Ftrojango#$user"
link1="trojan://${uuid}@isi_bug_disini:${trgo}/?sni=${domain}&type=ws&host=${domain}&path=%2Ftrojango#$user"
clear
echo -e "━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
echo -e "TROJAN GO" | tee -a /etc/log-create-user.log
echo -e "━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
echo -e "Remarks    : ${user}" | tee -a /etc/log-create-user.log
echo -e "Address    : ${domain}" | tee -a /etc/log-create-user.log
echo -e "Port       : ${trgo}" | tee -a /etc/log-create-user.log
echo -e "Key        : ${uuid}" | tee -a /etc/log-create-user.log
echo -e "Encryption : none" | tee -a /etc/log-create-user.log
echo -e "Path       : /trojango" | tee -a /etc/log-create-user.log
echo -e "Created    : $hariini" | tee -a /etc/log-create-user.log
echo -e "Expired    : $exp" | tee -a /etc/log-create-user.log
echo -e "━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
echo -e "Link TrGo  		: ${link}" | tee -a /etc/log-create-user.log
echo -e "Link TrGo (v2rayNG)	: ${link1}" | tee -a /etc/log-create-user.log
echo -e "━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
echo -e "THANKS FOR USING OUR SERVICE" | tee -a /etc/log-create-user.log
echo "" | tee -a /etc/log-create-user.log
sleep 1
systemctl restart trojan-go.service