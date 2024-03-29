#!/bin/bash
echo -e "
"
date
echo ""
domain=$(cat /root/domain)
sleep 1
mkdir -p /etc/xray 
echo -e "[ ${green}INFO${NC} ] Checking... "
sleep 1
echo -e "[ ${green}INFO$NC ] Setting dll"
apt clean all && apt update
apt install zip -y
apt install curl cron socat -y


# install xray
sleep 1
echo -e "[ ${green}INFO$NC ] Downloading & Installing xray core"
domainSock_dir="/run/xray";! [ -d $domainSock_dir ] && mkdir  $domainSock_dir
chown www-data.www-data $domainSock_dir

# Make Folder XRay
mkdir -p /var/log/xray
mkdir -p /etc/xray
chown www-data.www-data /var/log/xray
chmod +x /var/log/xray
touch /var/log/xray/access.log
touch /var/log/xray/error.log
touch /var/log/xray/access-trojan.log
touch /var/log/xray/error-trojan.log
touch /var/log/xray/access-vmess.log
touch /var/log/xray/error-vmess.log
touch /var/log/xray/access-vless.log
touch /var/log/xray/error-vless.log
touch /var/log/xray/access2.log
touch /var/log/xray/error2.log

# Ambil Xray Core Version Terbaru
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u www-data --version 1.7.5

## crt xray
systemctl stop nginx
mkdir /root/.acme.sh
curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc

# nginx renew ssl
echo -n '#!/bin/bash
/etc/init.d/nginx stop
"/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" &> /root/renew_ssl.log
/etc/init.d/nginx start
/etc/init.d/nginx status
' > /usr/local/bin/ssl_renew.sh
chmod +x /usr/local/bin/ssl_renew.sh
if ! grep -q 'ssl_renew.sh' /var/spool/cron/crontabs/root;then (crontab -l;echo "15 03 */3 * * /usr/local/bin/ssl_renew.sh") | crontab;fi

mkdir -p /home/vps/public_html

# set uuid
uuid=$(cat /proc/sys/kernel/random/uuid)

# trojan config
cat > /etc/xray/trojan.json << END
{
    "log" : {
      "access": "/var/log/xray/access-trojan.log",
      "error": "/var/log/xray/error-trojan.log",
      "loglevel": "warning"
    },
    "inbounds": [
        {
        "listen": "127.0.0.1",
        "port": 11111,
        "protocol": "dokodemo-door",
        "settings": {
          "address": "127.0.0.1"
        },
        "tag": "api"
      },
      {
        "listen": "/run/xray/trojan_ws.sock",
        "protocol": "trojan",
        "settings": {
            "decryption":"none",		
             "clients": [
                {
                   "password": "${uuid}"
#trojanws
                }
            ],
           "udp": true
         },
         "streamSettings":{
             "network": "ws",
             "wsSettings": {
                 "path": "/trojan-ws"
              }
           }
       },
       {
          "listen": "/run/xray/trojan_grpc.sock",
          "protocol": "trojan",
          "settings": {
            "decryption":"none",
               "clients": [
                 {
                   "password": "${uuid}"
#trojangrpc
                 }
             ]
          },
           "streamSettings":{
           "network": "grpc",
             "grpcSettings": {
                 "serviceName": "trojan-grpc"
           }
        }
     }
    ],
    "outbounds": [
      {
        "protocol": "freedom",
        "settings": {}
      },
      {
        "protocol": "blackhole",
        "settings": {},
        "tag": "blocked"
      }
    ],
    "routing": {
      "rules": [
        {
          "type": "field",
          "ip": [
            "0.0.0.0/8",
            "10.0.0.0/8",
            "100.64.0.0/10",
            "169.254.0.0/16",
            "172.16.0.0/12",
            "192.0.0.0/24",
            "192.0.2.0/24",
            "192.168.0.0/16",
            "198.18.0.0/15",
            "198.51.100.0/24",
            "203.0.113.0/24",
            "::1/128",
            "fc00::/7",
            "fe80::/10"
          ],
          "outboundTag": "blocked"
        },
        {
          "inboundTag": [
            "api"
          ],
          "outboundTag": "api",
          "type": "field"
        }
      ]
    },
    "stats": {},
    "api": {
      "services": [
        "StatsService"
      ],
      "tag": "api"
    },
    "policy": {
      "levels": {
        "0": {
          "statsUserDownlink": true,
          "statsUserUplink": true
        }
      },
      "system": {
        "statsInboundUplink": true,
        "statsInboundDownlink": true,
        "statsOutboundUplink" : true,
        "statsOutboundDownlink" : true
      }
    }
  }
END

# vmess config
cat > /etc/xray/vmess.json << END
{
    "log" : {
      "access": "/var/log/xray/access-vmess.log",
      "error": "/var/log/xray/error-vmess.log",
      "loglevel": "warning"
    },
    "inbounds": [
        {
        "listen": "127.0.0.1",
        "port": 22222,
        "protocol": "dokodemo-door",
        "settings": {
          "address": "127.0.0.1"
        },
        "tag": "api"
      },
       {
       "listen": "/run/xray/vmess_ws.sock",
       "protocol": "vmess",
        "settings": {
              "clients": [
                 {
                   "id": "${uuid}",
                   "alterId": 0
#vmess
               }
            ]
         },
         "streamSettings":{
           "network": "ws",
              "wsSettings": {
                  "path": "/vmess"
            }
          }
       },
       {
       "listen": "/run/xray/vmess_grpc.sock",
       "protocol": "vmess",
        "settings": {
              "clients": [
                 {
                   "id": "${uuid}",
                   "alterId": 0
#vmessgrpc
               }
            ]
         },
         "streamSettings":{
           "network": "grpc",
              "grpcSettings": {
                  "serviceName": "vmess-grpc"
            }
          }
       }
    ],
    "outbounds": [
      {
        "protocol": "freedom",
        "settings": {}
      },
      {
        "protocol": "blackhole",
        "settings": {},
        "tag": "blocked"
      }
    ],
    "routing": {
      "rules": [
        {
          "type": "field",
          "ip": [
            "0.0.0.0/8",
            "10.0.0.0/8",
            "100.64.0.0/10",
            "169.254.0.0/16",
            "172.16.0.0/12",
            "192.0.0.0/24",
            "192.0.2.0/24",
            "192.168.0.0/16",
            "198.18.0.0/15",
            "198.51.100.0/24",
            "203.0.113.0/24",
            "::1/128",
            "fc00::/7",
            "fe80::/10"
          ],
          "outboundTag": "blocked"
        },
        {
          "inboundTag": [
            "api"
          ],
          "outboundTag": "api",
          "type": "field"
        }
      ]
    },
    "stats": {},
    "api": {
      "services": [
        "StatsService"
      ],
      "tag": "api"
    },
    "policy": {
      "levels": {
        "0": {
          "statsUserDownlink": true,
          "statsUserUplink": true
        }
      },
      "system": {
        "statsInboundUplink": true,
        "statsInboundDownlink": true,
        "statsOutboundUplink" : true,
        "statsOutboundDownlink" : true
      }
    }
  }
END

# vless config
cat > /etc/xray/vless.json << END
{
    "log" : {
      "access": "/var/log/xray/access-vless.log",
      "error": "/var/log/xray/error-vless.log",
      "loglevel": "warning"
    },
    "inbounds": [
        {
        "listen": "127.0.0.1",
        "port": 33333,
        "protocol": "dokodemo-door",
        "settings": {
          "address": "127.0.0.1"
        },
        "tag": "api"
      },
     {
       "listen": "/run/xray/vless_ws.sock",
       "protocol": "vless",
        "settings": {
            "decryption":"none",
              "clients": [
                 {
                   "id": "$uuid"                 
#vless
               }
            ]
         },
         "streamSettings":{
           "network": "ws",
              "wsSettings": {
                  "path": "/vless"
            }
          }
       },
      {
       "listen": "/run/xray/vless_grpc.sock",
       "protocol": "vless",
        "settings": {
            "decryption":"none",
              "clients": [
                 {
                   "id": "$uuid" 
#vlessgrpc
               }
            ]
         },
            "streamSettings":{
               "network": "grpc",
               "grpcSettings": {
                  "serviceName": "vless-grpc"
             }
          }
       }
    ],
    "outbounds": [
      {
        "protocol": "freedom",
        "settings": {}
      },
      {
        "protocol": "blackhole",
        "settings": {},
        "tag": "blocked"
      }
    ],
    "routing": {
      "rules": [
        {
          "type": "field",
          "ip": [
            "0.0.0.0/8",
            "10.0.0.0/8",
            "100.64.0.0/10",
            "169.254.0.0/16",
            "172.16.0.0/12",
            "192.0.0.0/24",
            "192.0.2.0/24",
            "192.168.0.0/16",
            "198.18.0.0/15",
            "198.51.100.0/24",
            "203.0.113.0/24",
            "::1/128",
            "fc00::/7",
            "fe80::/10"
          ],
          "outboundTag": "blocked"
        },
        {
          "inboundTag": [
            "api"
          ],
          "outboundTag": "api",
          "type": "field"
        }
      ]
    },
    "stats": {},
    "api": {
      "services": [
        "StatsService"
      ],
      "tag": "api"
    },
    "policy": {
      "levels": {
        "0": {
          "statsUserDownlink": true,
          "statsUserUplink": true
        }
      },
      "system": {
        "statsInboundUplink": true,
        "statsInboundDownlink": true,
        "statsOutboundUplink" : true,
        "statsOutboundDownlink" : true
      }
    }
  }
END

rm -rf /etc/systemd/system/xray.service.d
rm -rf /etc/systemd/system/xray@.service

cat > /etc/systemd/system/trojan.service <<-END
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=www-data
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /etc/xray/trojan.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=100000000
LimitNOFILE=100000000

[Install]
WantedBy=multi-user.target
END

cat > /etc/systemd/system/vmess.service <<-END
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=www-data
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /etc/xray/vmess.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=100000000
LimitNOFILE=100000000

[Install]
WantedBy=multi-user.target
END

cat > /etc/systemd/system/vless.service <<-END
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=www-data
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /etc/xray/vless.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=100000000
LimitNOFILE=100000000

[Install]
WantedBy=multi-user.target
END

cat > /etc/systemd/system/runn.service <<EOF
[Unit]
Description=Mantap-Sayang
After=network.target

[Service]
Type=simple
ExecStartPre=-/usr/bin/mkdir -p /var/run/xray
ExecStart=/usr/bin/chown www-data:www-data /var/run/xray
Restart=on-abort
LimitNPROC=100000000
LimitNOFILE=100000000

[Install]
WantedBy=multi-user.target
EOF

#nginx config
cd /etc/nginx/conf.d/
wget -O xray.conf "https://raw.githubusercontent.com/presult77/script/main/xray.conf" && chmod +x xray.conf
cd

echo -e "$yell[SERVICE]$NC Restart All service"
systemctl daemon-reload
sleep 1
echo -e "[ ${green}ok${NC} ] Enable & restart xray "
systemctl daemon-reload
systemctl enable trojan
systemctl restart trojan
systemctl enable vmess
systemctl restart vmess
systemctl enable vless
systemctl restart vless
systemctl restart nginx
systemctl enable runn
systemctl restart runn
systemctl disable xray

# tweaking
echo "* soft nproc 1048576" >> /etc/security/limits.conf
echo "* hard nproc 1048576" >> /etc/security/limits.conf
echo "* soft nofile 1048576" >> /etc/security/limits.conf
echo "* hard nofile 1048576" >> /etc/security/limits.conf
echo "www-data soft nproc 1048576" >> /etc/security/limits.conf
echo "www-data hard nproc 1048576" >> /etc/security/limits.conf
echo "www-data soft nofile 1048576" >> /etc/security/limits.conf
echo "www-data hard nofile 1048576" >> /etc/security/limits.conf
echo "root soft nproc 1048576" >> /etc/security/limits.conf
echo "root hard nproc 1048576" >> /etc/security/limits.conf
echo "root soft nofile 1048576" >> /etc/security/limits.conf
echo "root hard nofile 1048576" >> /etc/security/limits.conf
echo "fs.file-max = 1048576" >> /etc/sysctl.conf
sudo sysctl -p

cd /usr/local/sbin/
# vmess
wget -O update "https://raw.githubusercontent.com/presult77/script/main/update.sh" && chmod +x update
wget -O add-ws "https://raw.githubusercontent.com/presult77/script/main/xray/add-ws.sh" && chmod +x add-ws
wget -O trialvmess "https://raw.githubusercontent.com/presult77/script/main/xray/trialvmess.sh" && chmod +x trialvmess
wget -O renew-ws "https://raw.githubusercontent.com/presult77/script/main/xray/renew-ws.sh" && chmod +x renew-ws
wget -O del-ws "https://raw.githubusercontent.com/presult77/script/main/xray/del-ws.sh" && chmod +x del-ws
wget -O cek-ws "https://raw.githubusercontent.com/presult77/script/main/xray/cek-ws.sh" && chmod +x cek-ws

# vless
wget -O add-vless "https://raw.githubusercontent.com/presult77/script/main/xray/add-vless.sh" && chmod +x add-vless
wget -O trialvless "https://raw.githubusercontent.com/presult77/script/main/xray/trialvless.sh" && chmod +x trialvless
wget -O renew-vless "https://raw.githubusercontent.com/presult77/script/main/xray/renew-vless.sh" && chmod +x renew-vless
wget -O del-vless "https://raw.githubusercontent.com/presult77/script/main/xray/del-vless.sh" && chmod +x del-vless
wget -O cek-vless "https://raw.githubusercontent.com/presult77/script/main/xray/cek-vless.sh" && chmod +x cek-vless

# trojan
wget -O add-tr "https://raw.githubusercontent.com/presult77/script/main/xray/add-tr.sh" && chmod +x add-tr
wget -O trialtrojan "https://raw.githubusercontent.com/presult77/script/main/xray/trialtrojan.sh" && chmod +x trialtrojan
wget -O del-tr "https://raw.githubusercontent.com/presult77/script/main/xray/del-tr.sh" && chmod +x del-tr
wget -O renew-tr "https://raw.githubusercontent.com/presult77/script/main/xray/renew-tr.sh" && chmod +x renew-tr
wget -O cek-tr "https://raw.githubusercontent.com/presult77/script/main/xray/cek-tr.sh" && chmod +x cek-tr

sleep 1
yellow() { echo -e "\\033[33;1m${*}\\033[0m"; }
yellow "xray/Vmess"
yellow "xray/Vless"

cd /usr/local/share/xray
rm geoip.dat
rm geosite.dat
wget https://github.com/malikshi/v2ray-rules-dat/releases/latest/download/geosite.dat
wget https://github.com/malikshi/v2ray-rules-dat/releases/latest/download/geoip.dat
cd

mv /root/domain /etc/xray/ 
if [ -f /root/scdomain ];then
rm /root/scdomain > /dev/null 2>&1
fi
clear
rm -f ins-xray.sh  
