#!/bin/bash

# Menghitung jumlah akun untuk setiap jenis server
trojan_accounts=$(grep -c -E "^#! " "/etc/xray/trojan.json")
vmess_accounts=$(grep -c -E "^### " "/etc/xray/vmess.json")
vless_accounts=$(grep -c -E "^#& " "/etc/xray/vless.json")

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
