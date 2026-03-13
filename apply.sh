#!/usr/bin/env bash

# ==========================================
# APPLY RICE - NixOS + Home Manager + Caelestia
# ==========================================

set -e

# Warna buat output biar cakep
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}>>> Memulai proses rebuild NixOS dengan Flake...${NC}"

# Pastikan kita di direktori yang benar (root config)
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

# 1. Update lockfile (opsional, tapi bagus buat pertama kali)
if [ ! -f "flake.lock" ]; then
    echo -e "${YELLOW}>>> Flake lockfile belum ada, melakukan update...${NC}"
    nix flake update
fi

# 2. Eksekusi rebuild
echo -e "${BLUE}>>> Menjalankan nh os switch...${NC}"
nh os switch . -- --accept-flake-config

echo -e "${GREEN}>>> REBUILD BERHASIL!${NC}"
echo -e "${BLUE}>>> Tips:${NC}"
echo -e "1. Restart Hyprland (Super + M) buat liat perubahannya."
echo -e "2. Coba ketik 'fetch' di terminal."
echo -e "3. Pake 'update' buat rebuild di masa depan."
echo -e "4. Pake 'clean' buat bersih-bersih disk."

# Optional: Kasih tau kalau butuh restart session
notify-send "NixOS Rebuild" "Selesai! Restart Hyprland untuk aktifkan Caelestia Shell."
