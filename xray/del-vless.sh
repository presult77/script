dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
#########################
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^#& " "/etc/xray/vless.json")
	if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
		echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo -e "\E[44;1;39m     ⇱ Delete Vless Account ⇲     \E[0m"
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━\033[0m"
		echo ""
		echo "You have no existing clients!"
		echo ""
		echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━\033[0m"
        exit
	fi
    clear
	echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\E[44;1;39m     ⇱ Delete Vless Account ⇲     \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo "  User       Expired  " 
	echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━\033[0m"
	grep -E "^#& " "/etc/xray/vless.json" | cut -d ' ' -f 2-3 | column -t | sort | uniq
    echo ""
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━\033[0m"
	read -rp "Input Username : " user
    CLIENT_EXISTS=$(grep -w $user /etc/xray/vless.json | wc -l)
    if [[ ${CLIENT_EXISTS} == '0' ]]; then
    exit 1
    else
    exp=$(grep -wE "^#& $user" "/etc/xray/vless.json" | cut -d ' ' -f 3 | sort | uniq)
    sed -i "/^#& $user $exp/,/^},{/d" /etc/xray/vless.json
    clear
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo " VLess Account Deleted Successfully"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo " Client Name : $user"
    echo " Expired On  : $exp"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    at now -f /root/restart-trojan.sh
    fi
