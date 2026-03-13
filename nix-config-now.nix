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
  boot.kernelPackages = pkgs.linuxPackages; # _latest;
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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Hardware & Performance
  hardware.enableAllFirmware = true;
  services.fstrim.enable = true;
  zramSwap.enable = true;
  services.auto-cpufreq.enable = true;
  services.flatpak.enable = true;

  # Nix Settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

# NH Configuration
programs.nh = {
  enable = true;
  clean.enable = true;
  clean.extraArgs = "--keep-since 4d --keep 3";
  flake = "/home/juang/Pictures/hyprland/hyprland-claude";
};

# List packages installed in system profile.
environment.systemPackages = with pkgs; [
  wget
  git
  htop gparted baobab
  bat                   # Pengganti cat yang cakep
  # --- Utilities ---
    wlr-randr             # Monitor management
    hyprpicker            # Color picker
    wev                   # Debug key events
    pciutils              # Buat cek lspci
    tuigreet              # Login manager
  ];

  # Fonts configuration
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
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

  # Services
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd hyprland";
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
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  security.polkit.enable = true;

  # NVIDIA Configuration
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
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

  system.stateVersion = "25.11"; 
}
