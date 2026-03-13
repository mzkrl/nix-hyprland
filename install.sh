#!/usr/bin/env bash
# ==========================================
# INSTALL SCRIPT — Deploy Hyprland Wayland
# Optimized for NixOS 25.11
# ==========================================

set -e

GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $1"; }
info() { echo -e "${BLUE}[→]${NC} $1"; }
warn() { echo -e "${ORANGE}[!]${NC} $1"; }

# ─── Preparation ────────────────────────────────
info "Preparing directories..."
mkdir -p ~/.config/{hypr,waybar,wofi,dunst,kitty}
mkdir -p ~/Pictures/Screenshots

# ─── Backup ─────────────────────────────────────
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=~/.config/hyprland-backup-$TIMESTAMP
info "Backing up old configs to $BACKUP_DIR..."

for dir in hypr waybar wofi dunst kitty; do
    if [ -d ~/.config/$dir ]; then
        mkdir -p "$BACKUP_DIR/$dir"
        cp -r ~/.config/$dir/* "$BACKUP_DIR/$dir/" 2>/dev/null || true
    fi
done

# ─── Deployment ─────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info "Deploying new configs..."
cp "$SCRIPT_DIR/hypr/hyprland.conf" ~/.config/hypr/
cp "$SCRIPT_DIR/hypr/hyprpaper.conf" ~/.config/hypr/
cp "$SCRIPT_DIR/hypr/hyprlock.conf" ~/.config/hypr/
cp "$SCRIPT_DIR/hypr/hypridle.conf" ~/.config/hypr/

cp "$SCRIPT_DIR/waybar/config.jsonc" ~/.config/waybar/config
cp "$SCRIPT_DIR/waybar/style.css" ~/.config/waybar/

cp "$SCRIPT_DIR/wofi/config" ~/.config/wofi/
cp "$SCRIPT_DIR/wofi/style.css" ~/.config/wofi/

cp "$SCRIPT_DIR/dunst/dunstrc" ~/.config/dunst/

cp "$SCRIPT_DIR/kitty/kitty.conf" ~/.config/kitty/

# ─── Permissions ────────────────────────────────
chmod +x ~/.config/hypr/hyprland.conf

log "Deployment complete!"
echo ""
warn "Next steps:"
echo "1. Put your wallpaper at ~/Pictures/wallpaper.jpg"
echo "2. Check your hardware Bus IDs in @nix-config-now.nix"
echo "3. Run 'sudo nixos-rebuild switch' to apply system changes"
echo "4. Press SUPER + M to exit and login back to see the magic!"
echo ""
