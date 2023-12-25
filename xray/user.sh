#!/bin/bash

# Menghitung jumlah akun untuk setiap jenis server
trojan_count=$(grep -c -E "^#! " "/etc/xray/trojan.json")
trojan_accounts=$((trojan_count / 2))
vmess_count=$(grep -c -E "^### " "/etc/xray/vmess.json")
vmess_accounts=$((vmess_count / 2))
vless_count=$(grep -c -E "^#& " "/etc/xray/vless.json")
vless_accounts=$((vless_count / 2))

# Menghitung total akun
total_accounts=$((trojan_accounts + vmess_accounts + vless_accounts))

# Fungsi untuk menampilkan teks dengan warna
print_color() {
  echo -e "\e[1;32m$1\e[0m"  # Warna hijau
}

# Menampilkan informasi dengan menggunakan echo dan warna
clear
echo "$(print_color "Total Server Account:")"
echo "Trojan: $trojan_accounts Account"
echo "Vmess: $vmess_accounts Account"
echo "Vless: $vless_accounts Account"
echo ""
echo "$(print_color "Total: $total_accounts Account")"
