# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = false;

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";

  boot.loader.grub.default = "saved";
  boot.loader.grub.configurationLimit = 5;
  boot.loader.grub.gfxmodeEfi = "1920x1200";

  boot.loader.grub.useOSProber = true;

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # Use latest kernel and NVIDIA optimizations for Hyprland
  boot.kernelPackages = pkgs.linuxPackages; # _latest;  #saat ini lagi ga pake yg latest, kenak masalah sama driver nvidia, tapi boleh di coba.
  boot.kernelParams = [ 
    "nvidia_drm.fbdev=1" 
    "nvidia-drm.modeset=1"
    "snd_intel_dspcfg.dsp_driver=3" # Force SOF driver for Intel Audio
  ];

  # Load necessary modules for Audio and Touchpad
  boot.initrd.kernelModules = [
 "i2c_hid_acpi"
# "snd_hda_intel"
 "snd_sof_pci_intel_tgl"
 ];

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Jakarta";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account.
  users.users.juang = {
    isNormalUser = true;
    description = "juang";
    extraGroups = [ "networkmanager" "wheel" "video" "input" "audio" ];
    shell = pkgs.fish;
  };
  programs.fish.enable = true;
  programs.nix-ld.enable = true;
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Hardware & Performance
  hardware.enableAllFirmware = false;
  hardware.enableRedistributableFirmware = true;
  services.fstrim.enable = true;
  zramSwap.enable = true;
  services.auto-cpufreq.enable = false; # Dimatikan karena konflik sama power-profiles-daemon
  services.power-profiles-daemon.enable = true;
  services.flatpak.enable = true;

  # Nix Settings
  nix.settings = {
  auto-optimise-store = true;

  # Trigger GC earlier when free space gets low.
  min-free = 4 * 1024 * 1024 * 1024;
  max-free = 8 * 1024 * 1024 * 1024;

  experimental-features = [ "nix-command" "flakes" ];

  substituters = [
    "https://cache.nixos.org"
    "https://hyprland.cachix.org"
  ];

  trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
  ];
};

# NH Configuration
programs.nh = {
  enable = true;
  clean.enable = true;
  clean.extraArgs = "--keep-since 7d --keep 3";
  flake = "/home/juang/Pictures/hyprland/hyprland-claude";
};

# List packages installed in system profile.
environment.systemPackages = with pkgs; [
  # --- Core System & Authentication ---
  polkit_gnome
  xhost
  (writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_SET_GUID=1
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '')
  tuigreet              # Login manager
  
  # --- General Utilities & CLI Basics ---
  wget curl git gh glab jq python3
  killall pciutils iproute2 procps
  bat htop btop eza fastfetch 
  #php php84Packages.composer #aih najis selesai uprak apus
  
  # --- Hardware & Disk Utilities ---
  gparted baobab wlr-randr
  pavucontrol brightnessctl playerctl
  libnotify

  # --- Main Applications ---
  brave discord antigravity-ide thunar tailscale #zed-editor #vscode #steam
];

  # Fonts configuration
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    nerd-fonts.comic-shanns-mono  # Icon font untuk cartoon-shell
    poppins
    noto-fonts
    noto-fonts-color-emoji
  ];

  # Desktop Environment (System Level)
  # Diperlukan untuk setuid wrappers dan portal sistem
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Wayland Environment Variables
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
  };

  # Services
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
        user = "juang";
      };
    };
  };

  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.blueman.enable = true;
  
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ];
  };

  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.login1.set-wall-message" ||
          action.id.indexOf("org.freedesktop.udisks2.") == 0) {
        if (subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      }
    });
  '';

  # NVIDIA Configuration
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # PRIME Configuration (Hybrid Graphics)
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # Ganti Bus ID ini sesuai hasil `lspci` lo kalo beda
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # ==========================================
  # PERSISTENT MOUNTS (Windows & Ubuntu)
  # ==========================================
  fileSystems."/mnt/windows" = {
    device = "/dev/disk/by-uuid/960C00360C001441";
    fsType = "ntfs-3g";
    # Mengizinkan execution dan akses full (rwxrwxrwx) agar game Steam & Proton bisa jalan
    options = [ "rw" "uid=1000" "gid=100" "umask=000" "exec" ];
  };

#   programs.steam = {
#   enable = true;
#   remotePlay.openFirewall = true; 
#   dedicatedServer.openFirewall = true;
# };

  fileSystems."/mnt/ubuntu" = {
    device = "/dev/disk/by-uuid/d6475f88-ab29-4e5c-bca2-49208daf86bd";
    fsType = "ext4";
    options = [ "defaults" ];
  };

  system.stateVersion = "25.11"; 
}
