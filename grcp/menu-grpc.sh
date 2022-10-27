#!/bin/bash
DF='\e[39m'
Bold='\e[1m'
Blink='\e[5m'
yell='\e[33m'
red='\e[31m'
green='\e[32m'
blue='\e[34m'
PURPLE='\e[35m'
CYAN='\e[36m'
Lred='\e[91m'
Lgreen='\e[92m'
Lyellow='\e[93m'
NC='\e[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
CYAN='\e[36m'
LIGHT='\033[0;37m'

clear
echo ""
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\E[44;1;39m                 ⇱  GRPC ADDON MENU  ⇲                    \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
echo -e " $blue[•1]$NC Create Grpc Vless Vmess Accounts                                   "
echo -e " $blue[•2]$NC Create Grpc Trojan Accounts                                   "
echo ""
echo -e " $blue[•3]$NC Delete Grpc Vless Vmess Accounts                                   "
echo -e " $blue[•4]$NC Delete Grpc Trojan Accounts                                 "
echo ""
echo -e " $blue[•5]$NC Renew XRay GRPC Accounts                                    "
echo -e " $blue[•6]$NC Renew XRay Trojan GRPC Accounts                                    "
echo ""
echo -e " $blue[•7]$NC Cek Grpc Vless Vmess Accounts                         "
echo -e " $blue[•8]$NC Cek Grpc Trojan Accounts                          "
echo ""
echo -e " $blue[•9]$NC Change Grpc Vless Vmess Accounts                                   "
echo -e " $blue[10]$NC Change Port Grpc Trojan Accounts                                       "

echo ""
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
echo -e " $blue[•x]$NC Main Menu                                                        " 
echo ""                                                 
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m" 
read -p "     Select From Options [1-10] :  " menu
case $menu in 
1) addgrpc ;;
2) addtrgrpc ;;
3) delgrpc ;;
4) deltrgrpc ;;
5) renewgrpc ;;
6) renewtrgrpc ;;
7) cekgrpc ;;
8) cektrgrpc ;;
9) port-grpc ;;
10) port-trgrpc ;;
x) menu ;;
*) echo "Input The Correct Number !" ;;
esac
