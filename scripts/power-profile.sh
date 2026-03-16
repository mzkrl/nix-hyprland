#!/usr/bin/env bash
# ==========================================
# Power Profile Manager
# Modes: performa, balance, hemat, ultra-hemat
# For: NixOS + Hyprland + NVIDIA RTX 2050 Laptop
# ==========================================

STATE_FILE="/tmp/power-profile-current"
NVIDIA_PCI="0000:01:00.0"

# Get current mode
get_current() {
    if [[ -f "$STATE_FILE" ]]; then
        cat "$STATE_FILE"
    else
        echo "balance"
    fi
}

# Set Hyprland animations
set_animations() {
    case "$1" in
        full)
            hyprctl keyword animations:enabled true
            hyprctl keyword decoration:blur:enabled true
            hyprctl keyword decoration:shadow:enabled true
            ;;
        reduced)
            hyprctl keyword animations:enabled true
            hyprctl keyword decoration:blur:enabled true
            hyprctl keyword decoration:shadow:enabled false
            ;;
        minimal)
            hyprctl keyword animations:enabled false
            hyprctl keyword decoration:blur:enabled false
            hyprctl keyword decoration:shadow:enabled false
            ;;
    esac
}

# NVIDIA GPU power control
gpu_off() {
    # Try to power down the NVIDIA GPU via runtime PM
    if [[ -d "/sys/bus/pci/devices/$NVIDIA_PCI" ]]; then
        echo "auto" | sudo tee "/sys/bus/pci/devices/$NVIDIA_PCI/power/control" > /dev/null 2>&1
        # Attempt to remove nvidia modules if possible
        sudo modprobe -r nvidia_uvm nvidia_drm nvidia_modeset nvidia 2>/dev/null
    fi
}

gpu_on() {
    # Restore NVIDIA GPU
    if [[ -d "/sys/bus/pci/devices/$NVIDIA_PCI" ]]; then
        echo "on" | sudo tee "/sys/bus/pci/devices/$NVIDIA_PCI/power/control" > /dev/null 2>&1
        # Reload modules
        sudo modprobe nvidia nvidia_modeset nvidia_drm nvidia_uvm 2>/dev/null
    fi
}

# Apply a profile
apply_profile() {
    local mode="$1"

    case "$mode" in
        performa)
            powerprofilesctl set performance
            # brightnessctl set 100% #gausah edit brightness lah, sakit mata euy
            set_animations full
            gpu_on
            notify-send -u normal -i battery-full-charging "⚡ Mode Performa" "CPU: performance | GPU: ON | Brightness: 100%"
            ;;
        balance)
            powerprofilesctl set balanced
            # brightnessctl set 70%
            set_animations full
            gpu_on
            notify-send -u normal -i battery-good "⚖️ Mode Balance" "CPU: balanced | GPU: ON (offload) | Brightness: 70%"
            ;;
        hemat)
            powerprofilesctl set power-saver
            # brightnessctl set 40%
            set_animations reduced
            gpu_on
            notify-send -u normal -i battery-low "🔋 Mode Hemat" "CPU: power-saver | GPU: ON (low) | Brightness: 40%"
            ;;
        ultra-hemat)
            powerprofilesctl set power-saver
            # brightnessctl set 25%
            set_animations minimal
            gpu_off
            notify-send -u normal -i battery-caution "🪫 Mode Ultra Hemat" "CPU: power-saver | GPU: OFF | Brightness: 25%"
            ;;
        *)
            echo "Unknown mode: $mode"
            exit 1
            ;;
    esac

    echo "$mode" > "$STATE_FILE"
}

# Cycle to the next profile
cycle() {
    local current
    current="$(get_current)"
    case "$current" in
        performa)     apply_profile "balance" ;;
        balance)      apply_profile "hemat" ;;
        hemat)        apply_profile "ultra-hemat" ;;
        ultra-hemat)  apply_profile "performa" ;;
        *)            apply_profile "balance" ;;
    esac
}

# Waybar output (JSON)
waybar_output() {
    local current icon tooltip css_class
    current="$(get_current)"
    case "$current" in
        performa)
            icon="⚡"
            tooltip="Mode Performa\nCPU: performance | GPU: ON"
            css_class="performance"
            ;;
        balance)
            icon="⚖️"
            tooltip="Mode Balance\nCPU: balanced | GPU: ON (offload)"
            css_class="balanced"
            ;;
        hemat)
            icon="🔋"
            tooltip="Mode Hemat\nCPU: power-saver | GPU: ON (low)"
            css_class="powersaver"
            ;;
        ultra-hemat)
            icon="🪫"
            tooltip="Mode Ultra Hemat\nCPU: power-saver | GPU: OFF"
            css_class="ultrasaver"
            ;;
        *)
            icon="⚖️"
            tooltip="Unknown"
            css_class="balanced"
            ;;
    esac

    # Escape for JSON
    tooltip="${tooltip//$'\n'/\\n}"
    echo "{\"text\": \"$icon\", \"tooltip\": \"$tooltip\", \"class\": \"$css_class\"}"
}

# Menu selection via fuzzel
menu() {
    local choice
    choice=$(printf "⚡ Performa\n⚖️ Balance\n🔋 Hemat\n🪫 Ultra Hemat" | fuzzel --dmenu --prompt "Power Profile: " --width 25 --lines 4)
    case "$choice" in
        *Performa*)    apply_profile "performa" ;;
        *Balance*)     apply_profile "balance" ;;
        *Hemat)        apply_profile "hemat" ;;
        *Ultra*)       apply_profile "ultra-hemat" ;;
    esac
}

# --- Main ---
case "${1:-}" in
    set)       apply_profile "$2" ;;
    cycle)     cycle ;;
    get)       get_current ;;
    waybar)    waybar_output ;;
    menu)      menu ;;
    *)
        echo "Usage: power-profile.sh {set <mode>|cycle|get|waybar|menu}"
        echo "Modes: performa, balance, hemat, ultra-hemat"
        exit 1
        ;;
esac
