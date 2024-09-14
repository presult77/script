#!/bin/bash

# Daftar layanan yang akan diperiksa
services=("trojan" "vmess" "vless")

# Loop melalui setiap layanan
for service in "${services[@]}"; do
    # Periksa status layanan
    status=$(systemctl status "$service" | grep "Active:")

    # Jika status tidak mengandung "active (running)", reboot
    if [[ ! "$status" =~ "active (running)" ]]; then
        echo "Service $service is not active (running). Rebooting..."
        reboot
        exit 1
    fi
done

echo "All services are active (running). No action needed."
