#!/bin/bash
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`

clear
domain=$(cat /etc/xray/domain)
tls="$(cat ~/log-install.txt | grep -w "Vless TLS" | cut -d: -f2|sed 's/ //g')"
none="$(cat ~/log-install.txt | grep -w "Vless None TLS" | cut -d: -f2|sed 's/ //g')"
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do


		read -rp "User: " -e user
		CLIENT_EXISTS=$(grep -w $user /etc/xray/vless.json | wc -l)

		if [[ ${CLIENT_EXISTS} == '1' ]]; then

		exit
		fi
	done

uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (days): " masaaktif
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#vless/a\#& '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user-ws""'"' /etc/xray/vless.json
sed -i '/#vlessgrpc/a\#& '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user-grpc""'"' /etc/xray/vless.json
vlesslink1="vless://${uuid}@${domain}:$tls?path=/vless&security=tls&encryption=none&type=ws#${user}"
vlesslink2="vless://${uuid}@${domain}:$none?path=/vless&encryption=none&type=ws#${user}"
vlesslink3="vless://${uuid}@${domain}:$tls?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=${domain}#${user}"

clear
echo -e "━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
echo -e "Trial 30 Minutes Vless Account" | tee -a /etc/log-create-user.log
echo -e "━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
echo -e "Username: ${user}" | tee -a /etc/log-create-user.log
echo -e "Expired: $exp" | tee -a /etc/log-create-user.log
echo -e "Domain: ${domain}" | tee -a /etc/log-create-user.log
echo -e "Port: TLS (443), nTLS (80, 8080), gRPC (443)" | tee -a /etc/log-create-user.log
echo -e "id: ${uuid}" | tee -a /etc/log-create-user.log
echo -e "Path: /vless" | tee -a /etc/log-create-user.log
echo -e "━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
echo -e "Link TLS : ${vlesslink1}" | tee -a /etc/log-create-user.log
echo -e "━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
echo -e "Link none TLS : ${vlesslink2}" | tee -a /etc/log-create-user.log
echo -e "━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
echo -e "Link GRPC : ${vlesslink3}" | tee -a /etc/log-create-user.log
echo -e "━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/log-create-user.log
echo -e "THANKS FOR USING OUR SERVICE" | tee -a /etc/log-create-user.log
at now -f /root/restart-vless.sh