#!/usr/bin/env bash
# Cek login Xray VLESS tanpa hapus log & tanpa sleep; cepat dan robust.

set -Eeuo pipefail
IFS=$'\n\t'

# === Konfigurasi ===
ACCESS_LOG="/var/log/xray/access-vless.log"
VLESS_JSON="/etc/xray/vless.json"
SERVICE_NAME="vless"        # ganti bila servicenya berbeda
SINCE_MINUTES=1             # window default kalau tidak restart

# === Warna (opsional) ===
red=$'\e[1;31m'
green=$'\e[0;32m'
NC=$'\e[0m'

usage() {
  cat <<USAGE
Pemakaian: $(basename "$0") [opsi]
  --since <menit>    : Baca log dalam <menit> terakhir (default: ${SINCE_MINUTES})
  --restart          : Restart service, lalu ambil log yang muncul setelahnya
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
      DO_RESTART=1; shift ;;
    --no-restart)
      DO_RESTART=0; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "Argumen tidak dikenal: $1"; usage; exit 1 ;;
  esac
done

[[ -r "$ACCESS_LOG" ]] || { echo "Gagal membaca $ACCESS_LOG"; exit 1; }
[[ -r "$VLESS_JSON" ]]  || { echo "Gagal membaca $VLESS_JSON"; exit 1; }

# Ambil daftar user dari vless.json
# Konvensi: baris yang dimulai '#&' diikuti username sebagai field ke-2
# Contoh: "#& user@example.com"
mapfile -t USERS < <(grep -E '^\s*#&' "$VLESS_JSON" | awk '{print $2}' | sort -u)
if [[ ${#USERS[@]} -eq 0 ]]; then
  echo "Tidak ditemukan user dari $VLESS_JSON (baris '#& <user>')."
fi

# Tentukan batas waktu pembacaan log
if [[ $DO_RESTART -eq 1 ]]; then
  start_epoch=$(date +%s)
  systemctl restart "$SERVICE_NAME" || { echo "Restart $SERVICE_NAME gagal"; exit 1; }
  echo -e "[ ${green}INFO${NC} ] Service direstart. Membaca log setelah $(date -d @"$start_epoch" '+%F %T')."
else
  start_epoch=$(date -d "-${SINCE_MINUTES} min" +%s)
  echo -e "[ ${green}INFO${NC} ] Membaca log ${SINCE_MINUTES} menit terakhir (sejak $(date -d @"$start_epoch" '+%F %T'))."
fi

# Proses log satu kali dengan AWK
awk -v start_epoch="$start_epoch" -v have_users="${#USERS[@]}" \
    -v users="$(printf '%s\n' "${USERS[@]-}" | tr '\n' ' ')" '
function to_epoch(datestr,   Y,M,D,h,m,s) {
  # Format timestamp Xray: "YYYY/MM/DD HH:MM:SS"
  gsub(/\//," ",datestr); gsub(/:/," ",datestr);
  split(datestr, a, /[[:space:]]+/);
  Y=a[1]; M=a[2]; D=a[3]; h=a[4]; m=a[5]; s=a[6];
  return mktime(sprintf("%04d %02d %02d %02d %02d %02d", Y,M,D,h,m,s));
}
BEGIN{
  split(users, uarr, /[[:space:]]+/);
  for (i in uarr) if (length(uarr[i])) known_user[uarr[i]]=1;
  print "-------------------------------";
  print "-----=[ Xray VLESS Login ]=-----";
  print "-------------------------------";
}
# Proses hanya baris yang punya timestamp diawal + mengandung "email"
$0 ~ /^[0-9]{4}\/[0-9]{2}\/[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}/ && $0 ~ /email/ {
  ts = substr($0,1,19);
  epoch = to_epoch(ts);
  if (epoch < start_epoch) next;

  # Field 3 biasanya ip:port (kadang diawali "tcp:")
  ipport = $3;
  sub(/^tcp:/,"",ipport);
  split(ipport, b, ":"); ip = b[1];

  # Ekstrak username dari token email
  uname="";
  for (i=1;i<=NF;i++) {
    if ($i == "email:" && (i+1)<=NF) { uname=$(i+1); break; }
    else if ($i ~ /^email=/) { split($i, tmp, "="); uname=tmp[2]; break; }
  }
  if (uname == "") next;
  gsub(/[;,]$/,"",uname);

  seen_ip[ip]=1;
  user_ip[uname,ip]=1;
  if (known_user[uname]) matched_ip[ip]=1;
}
END{
  # Cetak per-user
  for (u in known_user) {
    # kumpulkan IP untuk user u
    n=0;
    for (k in user_ip) {
      split(k, kk, SUBSEP);
      if (kk[1]==u) {
        n++; buf[n]=kk[2];
      }
    }
    if (n>0) {
      print "user : " u;
      for (i=1;i<=n;i++) printf("%d\t%s\n", i, buf[i]);
      print "-------------------------------";
      # kosongkan buffer
      delete buf;
    }
  }

  # Keluarkan OTHER: IP terlihat tapi tidak match user known mana pun
  print "other";
  idx=0;
  for (ip in seen_ip) if (!matched_ip[ip]) { idx++; other[idx]=ip; }
  if (idx==0) print "(kosong)";
  else for (i=1;i<=idx;i++) printf("%d\t%s\n", i, other[i]);
  print "-------------------------------";
}
' "$ACCESS_LOG"
