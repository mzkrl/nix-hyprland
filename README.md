<div align="center">

# 🚀 NixOS Hyprland Configuration

<img src="https://img.shields.io/badge/NixOS-unstable-blue?style=for-the-badge&logo=nixos&logoColor=white" alt="NixOS">
<img src="https://img.shields.io/badge/Hyprland-Wayland-teal?style=for-the-badge&logo=wayland&logoColor=white" alt="Hyprland">
<img src="https://img.shields.io/badge/NVIDIA-PRIME-76B900?style=for-the-badge&logo=nvidia&logoColor=white" alt="NVIDIA">
<img src="https://img.shields.io/badge/Home_Manager-enabled-orange?style=for-the-badge&logo=homeassistant&logoColor=white" alt="Home Manager">

**A modern, declarative NixOS desktop configuration featuring Hyprland compositor with NVIDIA PRIME support**

[Features](#-features) • [Installation](#-installation) • [Structure](#-project-structure) • [Customization](#-customization) • [Keybindings](#-keybindings)

---

</div>

## ✨ Features

### 🎨 **Modern Aesthetics**
- **Hyprland** - Dynamic tiling Wayland compositor with stunning animations
- **Anthropic Color Scheme** - Elegant dark theme with warm accents
- **SwayNC** - Modern notification center with control widgets
- **Fuzzel** - Fast and lightweight application launcher
- **Custom Theming** - Consistent GTK, Qt, and terminal theming

### ⚡ **Performance & Hardware**
- **NVIDIA PRIME** - Optimized hybrid graphics (Intel iGPU + NVIDIA dGPU)
- **Latest Kernel** - Using modern Linux kernel with optimizations
- **Hardware Acceleration** - Full VA-API and NVENC support
- **Power Management** - Multiple power profiles (performance, balanced, power-saver)
- **Zram Swap** - Compressed memory for better performance
- **Automatic TRIM** - SSD optimization enabled

### 🛠️ **Development Tools**
- **Neovim** - Modern, extensible text editor
- **Modern CLI Suite** - eza, zoxide, fzf, ripgrep, fd, bat
- **Fish Shell** - User-friendly shell with smart autocompletions
- **Starship Prompt** - Fast, customizable prompt
- **Direnv** - Automatic environment management
- **Git Tools** - gh (GitHub), glab (GitLab) CLI tools
- **Node.js & Bun** - Latest JavaScript runtimes

### 🎯 **Desktop Utilities**
- **Hyprlock** - Beautiful lockscreen with blur effects
- **Hypridle** - Intelligent idle management
- **Hyprpaper** - Wallpaper daemon
- **Btop** - Resource monitor with gorgeous UI
- **Cliphist** - Clipboard history manager
- **Grim + Slurp + Swappy** - Screenshot and annotation tools
- **Thunar** - Lightweight file manager with plugins

### 🔧 **System Features**
- **Flakes** - Reproducible, declarative system configuration
- **Home Manager** - User-level package and dotfile management
- **NH** - Nix Helper for easier system management
- **Automatic Cleanup** - Keep last 3 generations, 4 days
- **Cachix Integration** - Fast binary cache for Hyprland
- **GRUB Bootloader** - With OS detection for dual-boot setups

---

## 📦 What's Included

| Category | Tools |
|----------|-------|
| **Window Manager** | Hyprland, SwayNC, Fuzzel |
| **Terminal** | Kitty, Fish, Starship, Fastfetch |
| **Browsers** | Firefox, Brave |
| **Development** | Neovim, Git, Node.js, Bun, Direnv |
| **Media** | PipeWire, Pavucontrol, Playerctl |
| **Themes** | Adwaita Dark, Papirus Icons |
| **Utilities** | Btop, Thunar, Cliphist, NetworkManager |

---

## 🚀 Installation

### Prerequisites
- A working NixOS installation (or ready to install)
- UEFI boot system
- Basic understanding of Nix and NixOS

### Quick Start

1. **Clone this repository**
   ```bash
   git clone https://github.com/mzkrl/nix-hyprland.git
   cd nix-hyprland
   ```

2. **Edit hardware configuration**
   ```bash
   # Generate your hardware config
   sudo nixos-generate-config --show-hardware-config > nixos/hardware-configuration.nix
   ```

3. **Update system-specific settings**

   Edit `nixos/configuration.nix`:
   - Change hostname (line 44)
   - Update username from `juang` to your username (line 62)
   - Adjust timezone (line 50)
   - Update NVIDIA PRIME bus IDs if needed (lines 256-257)
     ```bash
     # Find your GPU bus IDs
     lspci | grep -E "VGA|3D"
     ```

4. **Update flake configuration**

   Edit `flake.nix`:
   - Change username in line 32 and 38 from `juang` to yours
   - Update hostname in line 22 if changed

5. **Update Home Manager paths**

   Edit `home/default.nix`:
   - Change username (line 6)
   - Update home directory (line 7)

6. **Update NH configuration path**

   Edit `nixos/configuration.nix` line 99:
   ```nix
   flake = "/path/to/your/nix-hyprland";
   ```

7. **Build and switch**
   ```bash
   # Initial installation (from NixOS installer or existing system)
   sudo nixos-rebuild switch --flake .#nixos

   # Or use NH helper (after first installation)
   nh os switch
   ```

8. **Reboot and enjoy!**
   ```bash
   sudo reboot
   ```

### Post-Installation

After first boot:

1. **Set wallpaper** - Place your wallpaper and update `configs/hypr/hyprpaper.conf`
2. **Configure display** - Adjust monitor settings in `configs/hypr/hyprland.conf`
3. **Test NVIDIA offload** - Run GPU-intensive apps with `nvidia-offload <command>`
4. **Check power profile** - Use `power` command to see/change power modes

---

## 📁 Project Structure

```
nix-hyprland/
├── flake.nix                      # Main flake configuration
├── flake.lock                     # Locked dependencies
├── nixos/
│   ├── configuration.nix          # System-level NixOS config
│   └── hardware-configuration.nix # Hardware-specific settings
├── home/
│   └── default.nix                # Home Manager user configuration
├── configs/
│   ├── hypr/
│   │   ├── hyprland.conf         # Hyprland main config
│   │   ├── theme.conf            # Color scheme and styling
│   │   └── hyprpaper.conf        # Wallpaper configuration
│   ├── swaync/
│   │   ├── config.json           # Notification center config
│   │   └── style.css             # Notification styling
│   └── fastfetch/
│       └── config.jsonc          # System info display config
└── scripts/
    ├── apply.sh                   # Quick apply script
    └── power-profile.sh           # Power management utility
```

---

## 🎨 Customization

### Changing Colors

The configuration uses Anthropic-inspired colors. To customize:

1. **Terminal (Kitty)** - Edit `home/default.nix`
2. **Fuzzel Launcher** - Edit `home/default.nix`
3. **Hyprland Theme** - Edit `configs/hypr/theme.conf`
5. **SwayNC** - Edit `configs/swaync/style.css`

### Adding Packages

**System-wide packages:**
```nix
# Edit nixos/configuration.nix, add to environment.systemPackages
environment.systemPackages = with pkgs; [
  your-package
];
```

**User packages:**
```nix
# Edit home/default.nix, add to home.packages
home.packages = with pkgs; [
  your-package
];
```

### Hyprland Configuration

Main config file: `configs/hypr/hyprland.conf`

- **Keybindings** - Search for `bind =` lines
- **Window Rules** - Search for `windowrule` lines
- **Animations** - Adjust in the `animation` section
- **Gaps & Borders** - Modify in `general` section

---

## ⌨️ Keybindings

### Essential Keybindings

| Key Combination | Action |
|----------------|--------|
| `SUPER + Q` | Launch terminal (Kitty) |
| `SUPER + D` | Application launcher (Fuzzel) |
| `SUPER + C` | Close active window |
| `SUPER + V` | Toggle floating mode |
| `SUPER + F` | Toggle fullscreen |
| `SUPER + E` | File manager (Thunar) |
| `SUPER + B` | Web browser (Firefox) |
| `SUPER + L` | Lock screen |
| `SUPER + M` | Exit/logout menu |

### Window Navigation

| Key Combination | Action |
|----------------|--------|
| `SUPER + ←/→/↑/↓` | Move focus |
| `SUPER + 1-9` | Switch to workspace |
| `SUPER + SHIFT + 1-9` | Move window to workspace |
| `SUPER + Mouse Left` | Move window |
| `SUPER + Mouse Right` | Resize window |
| `ALT + Tab` | Cycle windows |

### Utilities

| Key Combination | Action |
|----------------|--------|
| `Print` | Screenshot full screen |
| `SHIFT + Print` | Screenshot area |
| `SUPER + SHIFT + S` | Toggle special workspace |
| `SUPER + CTRL + V` | Clipboard history |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioRaiseVolume` | Increase volume |
| `XF86AudioLowerVolume` | Decrease volume |
| `XF86MonBrightnessUp` | Increase brightness |
| `XF86MonBrightnessDown` | Decrease brightness |

> **Note:** Check `configs/hypr/hyprland.conf` for complete keybinding list

---

## 🔧 Useful Commands

### System Management

```bash
# Update system
nh os switch

# Update home manager only
nh home switch

# Clean old generations
nh clean all

# Check system differences after rebuild
nvd diff /run/current-system result

# Search packages
nix search nixpkgs <package-name>
```

### Power Management

```bash
# These are shell aliases defined in home/default.nix

# View current power profile
power

# Switch to performance mode
performa

# Switch to balanced mode (alias for the script's "balance" profile)
hemat
# Or call the script directly:
power-profile.sh balance

# Switch to power-saver mode
ultra-hemat
```

### NVIDIA Commands

```bash
# Run app with NVIDIA GPU
nvidia-offload <command>

# Example: Run game with NVIDIA
nvidia-offload steam

# Check NVIDIA GPU status
nvidia-smi
```

### Development

```bash
# Use modern replacements
ls    # → eza with icons
cat   # → bat with syntax highlighting
cd    # → zoxide (smart cd)
fetch # → fastfetch system info
```

---

## 🐛 Troubleshooting

### NVIDIA Issues

If you experience graphics issues:

1. **Check bus IDs are correct:**
   ```bash
   lspci | grep -E "VGA|3D"
   ```
   Update in `nixos/configuration.nix` lines 256-257

2. **Verify NVIDIA is loaded:**
   ```bash
   lsmod | grep nvidia
   ```

3. **Check Hyprland is using correct GPU:**
   ```bash
   hyprctl monitors
   ```

### Audio Not Working

1. **Restart PipeWire:**
   ```bash
   systemctl --user restart pipewire pipewire-pulse wireplumber
   ```

2. **Check audio devices:**
   ```bash
   pactl list sinks
   ```

### Touchpad Issues

If touchpad doesn't work, ensure modules are loaded:
```bash
lsmod | grep i2c_hid
```

---

## 🤝 Contributing

Contributions are welcome! Feel free to:

- Report bugs
- Suggest features
- Submit pull requests
- Share your customizations

---

## 📝 License

This configuration is provided as-is for personal use and learning. Feel free to use, modify, and share.

---

## 🙏 Acknowledgments

- [NixOS](https://nixos.org/) - The purely functional Linux distribution
- [Hyprland](https://hyprland.org/) - Dynamic tiling Wayland compositor
- [Home Manager](https://github.com/nix-community/home-manager) - Dotfile management
- [Anthropic](https://www.anthropic.com/) - Color scheme inspiration

---

<div align="center">

**Built with ❤️ using NixOS and Hyprland**

⭐ Star this repo if you find it useful!

</div>
