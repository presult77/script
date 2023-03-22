#!/bin/bash
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`

clear
domain=$(cat /etc/xray/domain)
tr="$(cat ~/log-install.txt | grep -w "Trojan WS" | cut -d: -f2|sed 's/ //g')"
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${user_EXISTS} == '0' ]]; do

		read -rp "User: " -e user
		user_EXISTS=$(grep -w $user /etc/xray/trojan.json | wc -l)

		if [[ ${user_EXISTS} == '1' ]]; then
clear
		exit
		fi
	done

uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (days): " masaaktif
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#trojanws/a\#! '"$user $exp"'\
sed -i '/#trojangrpc/a\#! '"$user $exp"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/trojan.json

trojanlink1="trojan://${uuid}@${domain}:${tr}?mode=gun&security=tls&type=grpc&serviceName=trojan-grpc&sni=${domain}#${user}"
trojanlink="trojan://${uuid}@${domain}:${tr}?path=%2Ftrojan-ws&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
clear
echo -e "━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
echo -e "VIP TROJAN ACCOUNT" | tee -a /etc/log-create-user.log
echo -e "━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
echo -e "Username: ${user}" | tee -a /etc/log-create-user.log
echo -e "Expired: $exp" | tee -a /etc/log-create-user.log
echo -e "Domain: ${domain}" | tee -a /etc/log-create-user.log
echo -e "Port: ${tr}" | tee -a /etc/log-create-user.log
echo -e "Key: ${uuid}" | tee -a /etc/log-create-user.log
echo -e "Path: /trojan-ws" | tee -a /etc/log-create-user.log
echo -e "━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
echo -e "Link WS : ${trojanlink}" | tee -a /etc/log-create-user.log
echo -e "━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
echo -e "Link GRPC : ${trojanlink1}" | tee -a /etc/log-create-user.log
echo -e "━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
echo -e "THANKS FOR USING OUR SERVICE" | tee -a /etc/log-create-user.log
at now -f /root/restart-trojan.sh