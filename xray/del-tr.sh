#!/bin/bash
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
#########################
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^#! " "/etc/xray/trojan.json")
total=$(($NUMBER_OF_CLIENTS / 2))
	if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
		echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo -e "\E[44;1;39m     ⇱ Delete Trojan Account ⇲     \E[0m"
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━\033[0m"
		echo ""
		echo "You have no existing clients!"
		echo ""
		echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━\033[0m"
        exit
	fi
	clear
	echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m     ⇱ Delete Trojan Account ⇲     \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo "  User       Expired  " 
	echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━\033[0m"
	grep -E "^#! " "/etc/xray/trojan.json" | cut -d ' ' -f 2-3 | column -t | sort | uniq
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m Total Trojan User: $total \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━\033[0m"
	read -rp "Input Username : " user
    CLIENT_EXISTS=$(grep -w $user /etc/xray/trojan.json | wc -l)
    if [[ ${CLIENT_EXISTS} == '0' ]]; then
    exit 1
    else
    exp=$(grep -wE "^#! $user" "/etc/xray/trojan.json" | cut -d ' ' -f 3 | sort | uniq)
    sed -i "/^#! $user $exp/,/^},{/d" /etc/xray/trojan.json
    clear
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo " Trojan Account Deleted Successfully"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo " Client Name : $user"
    echo " Expired On  : $exp"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo "Regards"
    at now -f /root/restart-trojan.sh
    fi
