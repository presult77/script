#!/bin/bash
#
# ==================================================

# initializing var
export DEBIAN_FRONTEND=noninteractive
MYIP=$(wget -qO- ipinfo.io/ip);
MYIP2="s/xxxxxxxxx/$MYIP/g";
NET=$(ip -o $ANU -4 route show to default | awk '{print $5}');
source /etc/os-release
ver=$VERSION_ID

#detail nama perusahaan
country=ID
state=Indonesia
locality=none
organization=none
organizationalunit=none
commonname=none
email=admin@naravpn.com

# simple password minimal
curl -sS https://raw.githubusercontent.com/presult77/script/main/ssh/password | openssl aes-256-cbc -d -a -pass pass:scvps07gg -pbkdf2 > /etc/pam.d/common-password
chmod +x /etc/pam.d/common-password

# go to root
cd

# Edit file /etc/systemd/system/rc-local.service
cat > /etc/systemd/system/rc-local.service <<-END
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
END

# nano /etc/rc.local
cat > /etc/rc.local <<-END
#!/bin/sh -e
# rc.local
# By default this script does nothing.
exit 0
END

# Ubah izin akses
chmod +x /etc/rc.local

# enable rc local
systemctl enable rc-local
systemctl start rc-local.service

#update
apt update -y
apt upgrade -y
apt dist-upgrade -y
apt-get remove --purge exim4 -y

# install wget and curl
apt -y install wget curl

# set time GMT +08
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config

install_ssl(){
    if [ -f "/usr/bin/apt-get" ];then
            isDebian=`cat /etc/issue|grep Debian`
            if [ "$isDebian" != "" ];then
                    apt-get install -y nginx certbot
                    apt install -y nginx certbot
                    sleep 3s
            else
                    apt-get install -y nginx certbot
                    apt install -y nginx certbot
                    sleep 3s
            fi
    else
        yum install -y nginx certbot
        sleep 3s
    fi

    systemctl stop nginx.service

    if [ -f "/usr/bin/apt-get" ];then
            isDebian=`cat /etc/issue|grep Debian`
            if [ "$isDebian" != "" ];then
                    echo "A" | certbot certonly --renew-by-default --register-unsafely-without-email --standalone -d $domain
                    sleep 3s
            else
                    echo "A" | certbot certonly --renew-by-default --register-unsafely-without-email --standalone -d $domain
                    sleep 3s
            fi
    else
        echo "Y" | certbot certonly --renew-by-default --register-unsafely-without-email --standalone -d $domain
        sleep 3s
    fi
}

# install webserver
apt -y install nginx
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
rm /etc/nginx/
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/presult77/script/main/ssh/nginx.conf"
mkdir -p /home/vps/public_html
/etc/init.d/nginx restart

# setting port ssh
cd
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 22' /etc/ssh/sshd_config
/etc/init.d/ssh restart

# install fail2ban
apt -y install fail2ban

# download script
cd /root
wget -O restart-trojan.sh "https://raw.githubusercontent.com/presult77/script/main/xray/restart-trojan.sh" && chmod +x restart-trojan.sh
wget -O restart-vmess.sh "https://raw.githubusercontent.com/presult77/script/main/xray/restart-vmess.sh" && chmod +x restart-vmess.sh
wget -O restart-vless.sh "https://raw.githubusercontent.com/presult77/script/main/xray/restart-vless.sh" && chmod +x restart-vless.sh

cd /usr/local/sbin/
# menu
wget -O menu "https://raw.githubusercontent.com/presult77/script/main/menu/menu.sh"
wget -O menu-vmess "https://raw.githubusercontent.com/presult77/script/main/menu/menu-vmess.sh"
wget -O menu-vless "https://raw.githubusercontent.com/presult77/script/main/menu/menu-vless.sh"
wget -O running "https://raw.githubusercontent.com/presult77/script/main/menu/running.sh"
wget -O clearcache "https://raw.githubusercontent.com/presult77/script/main/menu/clearcache.sh"
wget -O menu-trojan "https://raw.githubusercontent.com/presult77/script/main/menu/menu-trojan.sh"

# menu system
wget -O menu-set "https://raw.githubusercontent.com/presult77/script/main/menu/menu-set.sh"
wget -O menu-domain "https://raw.githubusercontent.com/presult77/script/main/menu/menu-domain.sh"
wget -O add-host "https://raw.githubusercontent.com/presult77/script/main/ssh/add-host.sh"
wget -O certv2ray "https://raw.githubusercontent.com/presult77/script/main/xray/certv2ray.sh"
wget -O menu-webmin "https://raw.githubusercontent.com/presult77/script/main/menu/menu-webmin.sh"
wget -O speedtest "https://raw.githubusercontent.com/presult77/script/main/ssh/speedtest_cli.py"
wget -O about "https://raw.githubusercontent.com/presult77/script/main/menu/about.sh"
wget -O auto-reboot "https://raw.githubusercontent.com/presult77/script/main/menu/auto-reboot.sh"
wget -O restart "https://raw.githubusercontent.com/presult77/script/main/menu/restart.sh"
wget -O bw "https://raw.githubusercontent.com/presult77/script/main/menu/bw.sh"

wget -O xp "https://raw.githubusercontent.com/presult77/script/main/ssh/xp.sh"
wget -O acs-set "https://raw.githubusercontent.com/presult77/script/main/acs-set.sh"

chmod +x menu
chmod +x menu-vmess
chmod +x menu-vless
chmod +x running
chmod +x clearcache
chmod +x menu-trojan

chmod +x menu-set
chmod +x menu-domain
chmod +x add-host
chmod +x certv2ray
chmod +x menu-webmin
chmod +x speedtest
chmod +x about
chmod +x auto-reboot
chmod +x restart
chmod +x bw

chmod +x xp
chmod +x acs-set
cd

cat > /etc/cron.d/re_otm <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 2 * * * root /sbin/reboot
END

#cat > /etc/cron.d/xp_otm <<-END
#SHELL=/bin/sh
#PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
#0 0 * * * root /usr/bin/xp
#END

cat > /home/re_otm <<-END
7
END

service cron restart >/dev/null 2>&1
service cron reload >/dev/null 2>&1

# remove unnecessary files
sleep 1
echo -e "[ ${green}INFO$NC ] Clearing trash"
apt autoclean -y >/dev/null 2>&1

if dpkg -s unscd >/dev/null 2>&1; then
apt -y remove --purge unscd >/dev/null 2>&1
fi

apt-get -y --purge remove samba* >/dev/null 2>&1
apt-get -y --purge remove apache2* >/dev/null 2>&1
apt-get -y --purge remove bind9* >/dev/null 2>&1
apt-get -y remove sendmail* >/dev/null 2>&1
apt autoremove -y >/dev/null 2>&1
# finishing
cd
chown -R www-data:www-data /home/vps/public_html
sleep 1
echo -e "$yell[SERVICE]$NC Restart All service"
/etc/init.d/nginx restart >/dev/null 2>&1
sleep 1
echo -e "[ ${green}ok${NC} ] Restarting nginx"
/etc/init.d/ssh restart >/dev/null 2>&1
sleep 1
echo -e "[ ${green}ok${NC} ] Restarting ssh "
/etc/init.d/fail2ban restart >/dev/null 2>&1
sleep 1
echo -e "[ ${green}ok${NC} ] Restarting fail2ban "
/etc/init.d/vnstat restart >/dev/null 2>&1
sleep 1
echo -e "[ ${green}ok${NC} ] Restarting vnstat "

history -c
echo "unset HISTFILE" >> /etc/profile


rm -f /root/key.pem
rm -f /root/cert.pem
rm -f /root/ssh-vpn.sh
rm -f /root/bbr.sh

# finihsing
clear
