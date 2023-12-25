#!/bin/bash

cd /usr/local/sbin/
rm update
wget -O update "https://raw.githubusercontent.com/presult77/script/main/update.sh" && chmod +x update

# vmess
rm /usr/local/sbin/add-ws
rm /usr/local/sbin/trialvmess
rm /usr/local/sbin/del-ws
rm /usr/local/sbin/renew-ws
rm /usr/local/sbin/cek-ws
wget -O add-ws "https://raw.githubusercontent.com/presult77/script/main/xray/add-ws.sh" && chmod +x add-ws
wget -O trialvmess "https://raw.githubusercontent.com/presult77/script/main/xray/trialvmess.sh" && chmod +x trialvmess
wget -O renew-ws "https://raw.githubusercontent.com/presult77/script/main/xray/renew-ws.sh" && chmod +x renew-ws
wget -O del-ws "https://raw.githubusercontent.com/presult77/script/main/xray/del-ws.sh" && chmod +x del-ws
wget -O cek-ws "https://raw.githubusercontent.com/presult77/script/main/xray/cek-ws.sh" && chmod +x cek-ws

# vless
rm /usr/local/sbin/add-vless
rm /usr/local/sbin/trialvless
rm /usr/local/sbin/del-vless
rm /usr/local/sbin/renew-vless
wget -O add-vless "https://raw.githubusercontent.com/presult77/script/main/xray/add-vless.sh" && chmod +x add-vless
wget -O trialvless "https://raw.githubusercontent.com/presult77/script/main/xray/trialvless.sh" && chmod +x trialvless
wget -O renew-vless "https://raw.githubusercontent.com/presult77/script/main/xray/renew-vless.sh" && chmod +x renew-vless
wget -O del-vless "https://raw.githubusercontent.com/presult77/script/main/xray/del-vless.sh" && chmod +x del-vless
wget -O cek-vless "https://raw.githubusercontent.com/presult77/script/main/xray/cek-vless.sh" && chmod +x cek-vless

# trojan
rm /usr/local/sbin/add-tr
rm /usr/local/sbin/trialtrojan
rm /usr/local/sbin/del-tr
rm /usr/local/sbin/renew-tr
rm /usr/local/sbin/cek-tr
rm /usr/local/sbin/menu
wget -O add-tr "https://raw.githubusercontent.com/presult77/script/main/xray/add-tr.sh" && chmod +x add-tr
wget -O trialtrojan "https://raw.githubusercontent.com/presult77/script/main/xray/trialtrojan.sh" && chmod +x trialtrojan
wget -O del-tr "https://raw.githubusercontent.com/presult77/script/main/xray/del-tr.sh" && chmod +x del-tr
wget -O renew-tr "https://raw.githubusercontent.com/presult77/script/main/xray/renew-tr.sh" && chmod +x renew-tr
wget -O cek-tr "https://raw.githubusercontent.com/presult77/script/main/xray/cek-tr.sh" && chmod +x cek-tr
wget -O menu "https://raw.githubusercontent.com/presult77/script/main/menu/menu.sh" && chmod +x menu

#totaluser
wget -O user "https://raw.githubusercontent.com/presult77/script/main/xray/user.sh" && chmod +x user

cd /root
#restart
rm restart.sh
wget -O restart-trojan.sh "https://raw.githubusercontent.com/presult77/script/main/xray/restart-trojan.sh" && chmod +x restart-trojan.sh
wget -O restart-vmess.sh "https://raw.githubusercontent.com/presult77/script/main/xray/restart-vmess.sh" && chmod +x restart-vmess.sh
wget -O restart-vless.sh "https://raw.githubusercontent.com/presult77/script/main/xray/restart-vless.sh" && chmod +x restart-vless.sh

ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
