systemctl stop xray.service

cd /etc/xray
mkdir –m777 grpc
cd
read -p "Press Enter to Continue : "
sleep 1

mkdir /etc/xray/grpc
cd /usr/bin

wget -O port-trgrpc "https://raw.githubusercontent.com/izhanworks/addongrpc/main/addongrpc2/port-trgrpc.sh"
chmod +x port-trgrpc

wget -O port-grpc "https://raw.githubusercontent.com/izhanworks/addongrpc/main/addongrpc2/port-grpc.sh"
chmod +x port-grpc 

wget -O menu-grpc "https://raw.githubusercontent.com/izhanworks/addongrpc/main/addongrpc2/menu-grpc.sh"
chmod +x menu-grpc
read -p "Press Enter to Continue : "
sleep 1

service squid start
domain=$(cat /etc/xray/domain)
uuid=$(cat /proc/sys/kernel/random/uuid)

cat > /etc/systemd/system/trgrpc.service << EOF
[Unit]
Description=XRay Trojan Grpc Service
Documentation=https://speedtest.net https://github.com/XTLS/Xray-core
After=network.target nss-lookup.target
[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/bin/xray/xray -config /etc/xray/grpc/trojangrpc.json
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000
[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/vless-grpc.service << EOF
[Unit]
Description=XRay VMess GRPC Service
Documentation=https://speedtest.net https://github.com/XTLS/Xray-core
After=network.target nss-lookup.target
[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/bin/xray/xray -config /etc/xray/grpc/vlessgrpc.json
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000
[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/vmess-grpc.service << EOF
[Unit]
Description=XRay VMess GRPC Service
Documentation=https://speedtest.net https://github.com/XTLS/Xray-core
After=network.target nss-lookup.target
[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/bin/xray/xray -config /etc/xray/grpc/vmessgrpc.json
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000
[Install]
WantedBy=multi-user.target
EOF

read -p "Press Enter to Continue : "
sleep 1

cat > /etc/xray/grpc/vmessgrpc.json << EOF
{
    "log": {
            "access": "/var/log/xray/access.log",
        "error": "/var/log/xray/error.log",
        "loglevel": "info"
    },
    "inbounds": [
        {
            "port": 800,
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "${uuid}"
#vmessgrpc
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "gun",
                "security": "tls",
                "tlsSettings": {
                    "serverName": "${domain}",
                    "alpn": [
                        "h2"
                    ],
                    "certificates": [
                        {
                            "certificateFile": "/root/.acme.sh/${domain}_ecc/fullchain.cer",
                            "keyFile": "/root/.acme.sh/${domain}_ecc/${domain}.key"
                        }
                    ]
                },
                "grpcSettings": {
                    "serviceName": "GunService"
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        }
    ]
}
EOF

cat > /etc/xray/grpc/vlessgrpc.json << EOF
{
    "log": {
            "access": "/var/log/xray/access.log",
        "error": "/var/log/xray/error.log",
        "loglevel": "info"
    },
    "inbounds": [
        {
            "port": 880,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "${uuid}"
#vlessgrpc
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "gun",
                "security": "tls",
                "tlsSettings": {
                    "serverName": "${domain}",
                    "alpn": [
                        "h2"
                    ],
                    "certificates": [
                        {
                            "certificateFile": "/root/.acme.sh/${domain}_ecc/fullchain.cer",
                            "keyFile": "/root/.acme.sh/${domain}_ecc/${domain}.key"
                        }
                    ]
                },
                "grpcSettings": {
                    "serviceName": "GunService"
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        }
    ]
}
EOF

cat > /etc/xray/grpc/trojangrpc.json << EOF
{
    "log": {
            "access": "/var/log/xray/access.log",
        "error": "/var/log/xray/error.log",
        "loglevel": "info"
    },
    "inbounds": [
        {
            "port": 653,
            "protocol": "trojan",
            "settings": {
                "clients": [
                    {
                        "password": "${uuid}"
#xtrgrpc
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "gun",
                "security": "tls",
                "tlsSettings": {
                    "serverName": "$domain",
                    "alpn": [
                        "h2"
                    ],
                    "certificates": [
                        {
                            "certificateFile": "/root/.acme.sh/${domain}_ecc/fullchain.cer",
                            "keyFile": "/root/.acme.sh/${domain}_ecc/${domain}.key"
                        }
                    ]
                },
                "grpcSettings": {
                    "serviceName": "GunService"
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        }
    ]
}
EOF

cat > /etc/xray/grpc/akuntrgrpc.conf << EOF
#xray-trojangrpc user
EOF

read -p "Press Enter to Continue : "
sleep 1

iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 800 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 800 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 880 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 880 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 653 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 653 -j ACCEPT


iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload
systemctl daemon-reload
systemctl enable vmess-grpc
systemctl restart vmess-grpc
systemctl enable vless-grpc
systemctl restart vless-grpc
systemctl enable trgrpc.service
systemctl start trgrpc.service
systemctl restart xray.service

wget -O addgrpc "https://raw.githubusercontent.com/izhanworks/addongrpc/main/addongrpc2/addgrpc.sh"
wget -O delgrpc "https://raw.githubusercontent.com/izhanworks/addongrpc/main/addongrpc2/delgrpc.sh"
wget -O cekgrpc "https://raw.githubusercontent.com/izhanworks/addongrpc/main/addongrpc2/cekgrpc.sh"
wget -O renewgrpc "https://raw.githubusercontent.com/izhanworks/addongrpc/main/addongrpc2/renewgrpc.sh"

wget -O addtrgrpc "https://raw.githubusercontent.com/izhanworks/addongrpc/main/addongrpc2/addtrgrpc.sh"
wget -O deltrgrpc "https://raw.githubusercontent.com/izhanworks/addongrpc/main/addongrpc2/deltrgrpc.sh"
wget -O cektrgrpc "https://raw.githubusercontent.com/izhanworks/addongrpc/main/addongrpc2/cektrgrpc.sh"
wget -O renewtrgrpc "https://raw.githubusercontent.com/izhanworks/addongrpc/main/addongrpc2/renewtrgrpc.sh"

chmod +x addgrpc
chmod +x delgrpc
chmod +x cekgrpc
chmod +x renewgrpc

chmod +x addtrgrpc
chmod +x deltrgrpc
chmod +x cektrgrpc
chmod +x renewtrgrpc

cd
rm /root/instgrpc.sh
systemctl start xray.service
read -p "Press Enter to Continue : "
sleep 1
