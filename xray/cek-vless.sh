#!/bin/bash
rm /var/log/xray/access-vless.log
rm /var/log/xray/error-vless.log
systemctl restart vless
clear
echo -e "[ ${green}INFO${NC} ] Waiting client connection"
sleep 30
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
ipp=$(cat /var/log/xray/access-vless.log | grep email | awk '{print $3}' | cut -d: -f1 | tr -d 'tcp' | sort | uniq)
cat > /root/ip.txt <<-END
$ipp
END
clear
echo -n > /tmp/other.txt
data=(`cat /etc/xray/vless.json | grep '^#&' | cut -d ' ' -f 2 | column -t | sort | uniq`);
echo "-------------------------------";
echo "-----=[ Xray Vless Login ]=-----";
echo "-------------------------------";
for akun in "${data[@]}"
do
if [[ -z "$akun" ]]; then
akun="tidakada"
fi
echo -n > /tmp/ipvless.txt
data2=( `cat /root/ip.txt`);
for ip in "${data2[@]}"
do
jum=$(cat /var/log/xray/access-vless.log | grep -w $akun | awk '{print $3}' | cut -d: -f1 | grep -w $ip | sort | uniq)
if [[ "$jum" = "$ip" ]]; then
echo "$jum" >> /tmp/ipvless.txt
else
echo "$ip" >> /tmp/other.txt
fi
jum2=$(cat /tmp/ipvless.txt)
sed -i "/$jum2/d" /tmp/other.txt > /dev/null 2>&1
done
jum=$(cat /tmp/ipvless.txt)
if [[ -z "$jum" ]]; then
echo > /dev/null
else
jum2=$(cat /tmp/ipvless.txt | nl)
echo "user : $akun";
echo "$jum2";
echo "-------------------------------"
fi
rm -rf /tmp/ipvless.txt
done
oth=$(cat /tmp/other.txt | sort | uniq | nl)
echo "other";
echo "$oth";
echo "-------------------------------"
rm -rf /tmp/other.txt
rm /root/ip.txt