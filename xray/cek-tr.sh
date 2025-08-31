#!/usr/bin/env bash
# Cek login Xray Trojan dengan cepat, tanpa hapus log & tanpa sleep.
# Menampilkan daftar IP yang terhubung per user, plus "other" (IP tak terpetakan).

set -Eeuo pipefail
IFS=$'\n\t'

# === Konfigurasi ===
ACCESS_LOG="/var/log/xray/access-trojan.log"
TROJAN_JSON="/etc/xray/trojan.json"
SERVICE_NAME="trojan"     # ganti jika nama servicenya lain
SINCE_MINUTES=1           # window waktu default bila tidak restart

# === Warna ===
red=$'\e[1;31m'
green=$'\e[0;32m'
NC=$'\e[0m'

usage() {
  cat <<USAGE
Pemakaian: $(basename "$0") [opsi]
  --since <menit>    : Baca log dalam <menit> terakhir (default: ${SINCE_MINUTES})
  --restart          : Restart service lalu hanya baca log yang muncul setelahnya
  --no-restart       : Jangan restart (default)
  -h|--help          : Tampilkan bantuan
Contoh:
  $(basename "$0") --since 15
  $(basename "$0") --restart
USAGE
}

DO_RESTART=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --since)
      SINCE_MINUTES="${2:-}"
      [[ -z "$SINCE_MINUTES" || ! "$SINCE_MINUTES" =~ ^[0-9]+$ ]] && { echo "Argumen --since harus angka menit"; exit 1; }
      shift 2
      ;;
    --restart)
      DO_RESTART=1
      shift
      ;;
    --no-restart)
      DO_RESTART=0
      shift
      ;;
    -h|--help)
      usage; exit 0
      ;;
    *)
      echo "Argumen tidak dikenal: $1"; usage; exit 1
      ;;
  esac
done

[[ -r "$ACCESS_LOG" ]] || { echo "Gagal membaca $ACCESS_LOG"; exit 1; }
[[ -r "$TROJAN_JSON" ]] || { echo "Gagal membaca $TROJAN_JSON"; exit 1; }

# Ambil daftar user dari TROJAN_JSON
# Konvensi: baris yang dimulai '#!' diikuti username sebagai field ke-2
# Contoh: "#! user@example.com"
mapfile -t USERS < <(grep -E '^\s*#!' "$TROJAN_JSON" | awk '{print $2}' | sort -u)
if [[ ${#USERS[@]} -eq 0 ]]; then
  echo "Tidak ditemukan user dari $TROJAN_JSON (baris '#! <user>')."
fi

start_epoch=""
if [[ $DO_RESTART -eq 1 ]]; then
  # Catat waktu sebelum restart, lalu restart
  start_epoch=$(date +%s)
  systemctl restart "$SERVICE_NAME" || { echo "Restart $SERVICE_NAME gagal"; exit 1; }
  echo -e "[ ${green}INFO${NC} ] Service direstart. Mengambil log yang muncul setelah $(date -d @"$start_epoch" '+%F %T')."
else
  # Mode tanpa restart: batasi ke X menit terakhir
  start_epoch=$(date -d "-${SINCE_MINUTES} min" +%s)
  echo -e "[ ${green}INFO${NC} ] Membaca log ${SINCE_MINUTES} menit terakhir (sejak $(date -d @"$start_epoch" '+%F %T'))."
fi

# Fungsi AWK:
# - Filter baris sejak start_epoch (format timestamp log Xray: "YYYY/MM/DD HH:MM:SS ...")
# - Ambil field ke-3 (IP:port) dan token "email:" lalu username setelahnya.
# - Bangun mapping user -> set IP dan kumpulkan IP "other" (yang tidak cocok user terdaftar).
awk -v start_epoch="$start_epoch" -v have_users="${#USERS[@]}" \
    -v users="$(printf '%s\n' "${USERS[@]-}" | tr '\n' ' ')" '
function to_epoch(datestr,   Y,M,D,h,m,s) {
  # datestr contoh: "2025/08/31 12:34:56"
  gsub(/\//," ",datestr); gsub(/:/," ",datestr);
  split(datestr, a, /[[:space:]]+/);
  Y=a[1]; M=a[2]; D=a[3]; h=a[4]; m=a[5]; s=a[6];
  return mktime(sprintf("%04d %02d %02d %02d %02d %02d", Y,M,D,h,m,s));
}
BEGIN{
  # muat daftar users ke hash known_user[uname]=1
  split(users, uarr, /[[:space:]]+/);
  for (i in uarr) if (length(uarr[i])) known_user[uarr[i]]=1;
}
# hanya proses baris yang punya pola timestamp + kata "email"
$0 ~ /^[0-9]{4}\/[0-9]{2}\/[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}/ && $0 ~ /email/ {
  ts = substr($0,1,19);
  epoch = to_epoch(ts);
  if (epoch < start_epoch) next;

  # field 3 biasanya ip:port
  ipport = $3;
  sub(/tcp:/,"",ipport);           # jika ada prefix tcp:
  split(ipport, b, ":"); ip = b[1];

  # cari token "email" dan ambil username setelahnya
  uname="";
  for (i=1;i<=NF;i++) {
    if ($i ~ /^email:$/ || $i ~ /email/) {
      # dua format umum: "email: user" ATAU "email=user"
      if ($i == "email:" && (i+1)<=NF) { uname=$(i+1); }
      else if ($i ~ /^email=/) { split($i, tmp, "="); uname=tmp[2]; }
      else if ($i ~ /^email:$/ && (i+1)<=NF) { uname=$(i+1); }
    }
  }
  if (uname == "") next;

  # normalisasi (buang koma/tanda baca trailing)
  gsub(/[;,]$/,"",uname);

  # simpan mapping
  seen_ip[ip]=1;
  user_ip[uname,ip]=1;

  # tandai ip yang match user known
  if (known_user[uname]) matched_ip[ip]=1;
}
END{
  print "-------------------------------";
  print "-----=[ Xray Trojan Login ]=-----";
  print "-------------------------------";

  # Cetak per user (hanya yang punya login)
  n_user_printed=0;
  for (u in known_user) {
    count=0;
    # kumpulkan IP untuk user u
    ips="";
    for (k in user_ip) {
      split(k, kk, SUBSEP);
      if (kk[1]==u) {
        ips=ips kk[2] "\n";
        count++;
      }
    }
    if (count>0) {
      n_user_printed++;
      print "user : " u;
      # nomor baris
      n=0; split("", lines);
      # urutkan kasar: kita tidak pakai sort eksternal; ini tetap cepat utk jumlah kecil
      # jadi langsung cetak bernomor
      split(ips, arr, "\n");
      for (i in arr) {
        if (length(arr[i])) {
          n++; printf("%d\t%s\n", n, arr[i]);
        }
      }
      print "-------------------------------";
    }
  }

  # Kumpulkan OTHER: IP yang terlihat tapi tidak match user known mana pun
  # (termasuk login dari user tak terdaftar/unknown)
  other_n=0;
  for (ip in seen_ip) {
    if (!matched_ip[ip]) {
      other_n++;
      other_list[other_n]=ip;
    }
  }
  print "other";
  if (other_n==0) {
    print "(kosong)";
  } else {
    for (i=1;i<=other_n;i++) printf("%d\t%s\n", i, other_list[i]);
  }
  print "-------------------------------";
}
' "$ACCESS_LOG"
