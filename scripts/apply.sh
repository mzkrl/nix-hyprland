#!/usr/bin/env bash
# ==========================================
# APPLY RICE - NixOS Flake + Home Manager
# ==========================================
# kinda deprecated
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${BLUE}>>> Rebuilding NixOS from flake: $DIR${NC}"

# Update lockfile kalau belum ada
if [ ! -f "$DIR/flake.lock" ]; then
    echo -e "${YELLOW}>>> Flake lockfile belum ada, melakukan update...${NC}"
    nix flake update --flake "$DIR"
fi

# Rebuild
nh os switch "$DIR" -- --accept-flake-config

echo -e "${GREEN}>>> REBUILD BERHASIL!${NC}"
echo -e "Tips:"
echo -e "  1. Restart Hyprland (SUPER+M) lalu login ulang"
echo -e "  2. Atau langsung: 'update' di terminal"
