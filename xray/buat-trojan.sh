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
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/trojan.json
sed -i '/#trojangrpc/a\#! '"$user $exp"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/trojan.json

trojanlink1="trojan://${uuid}@${domain}:${tr}?mode=gun&security=tls&type=grpc&serviceName=trojan-grpc&sni=${domain}#${user}"
trojanlink="trojan://${uuid}@${domain}:${tr}?path=%2Ftrojan-ws&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
clear
cat > /home/vps/public_html/trojan/${uuid}.txt << END
"====================="
"AKUN TROJAN VIP BANDWITH"
"====================="
"Domain: ${domain}"
"Username: ${user}"
"Expired: $exp"
"Port: ${tr}"
"Key: ${uuid}"
"Path: /trojan-ws"
"Path GRPC: trojan-grpc"
"====================="
"Link GRPC : ${trojanlink1}"
"====================="
"Link WS : ${trojanlink}"
"====================="
"TERIMAKASIH ATAS PEMBELIANNYA"
END
echo -e "====================="
echo -e "Terimakasih atas pembelian anda"
echo -e "====================="
echo -e "AKUN TROJAN VIP BANDWITH"
echo -e "Server: ${domain}"
echo -e "Expire: $exp"
echo -e "Link Akun: http://${domain}:81/trojan/${uuid}.txt"
echo -e "====================="
echo -e "Kontak Admin: t.me/rumahvpn_admin"
echo -e "Channel Telegram: t.me/rumahvpn_channel "
echo -e "====================="
systemctl restart trojan