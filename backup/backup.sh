#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
IP=$(wget -qO- icanhazip.com);
domain=$(cat /etc/xray/domain);
date=$(date +"%Y-%m-%d")
clear
echo " Enter Your Email To Receive Message"
read -rp " Email: " -e email
sleep 1
echo Membuat Directory
mkdir /root/backup
sleep 1
echo Start Backup
clear
cp -r /etc/xray backup/xray
cd /root
zip -r $domain-$date.zip backup > /dev/null 2>&1
rclone copy /root/$domain-$date.zip dr:backup/
url=$(rclone link dr:backup/$domain-$date.zip)
id=(`echo $url | grep '^https' | cut -d'=' -f2`)
link="https://drive.google.com/u/4/uc?id=${id}&export=download"
echo -e "The following is a link to your vps data backup file.

Your VPS Domain $domain

$link

If you want to restore data, please enter the link above.

Thank You For Using Our Services" | mail -s "Backup Data" $email
rm -rf /root/backup
rm -r /root/$domain-$date.zip
echo "Done"
echo "Please Check Your Email"