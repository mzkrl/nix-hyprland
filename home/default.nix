{ inputs, pkgs, lib, config, ... }: {
  # imports = [
  #   inputs.caelestia-shell.homeManagerModules.default
  # ];

  home.username = "juang";
  home.homeDirectory = "/home/juang";
  home.stateVersion = "25.11";

  # Caelestia Shell Configuration (DISABLED - BROKEN)
  # programs.caelestia = {
  #   enable = true;
  #   package = inputs.caelestia-shell.packages.${pkgs.system}.default;
  # };
  # User specific packages
  home.packages = with pkgs; [
    # Desktop Utilities
    waybar                # Fallback panel (backup)
    networkmanagerapplet
    pavucontrol
    brightnessctl
    playerctl
    wl-clipboard
    cliphist
    libnotify
    grim
    slurp
    swappy

    # Modern CLI Suite
    eza
    zoxide
    fzf
    fastfetch
    nh
    nix-output-monitor
    nvd
    btop                  # System monitor gahar
    bat                   # cat with wings

    # Apps
    firefox
    discord

    # Dev & Terminal
    git
    gh
    glab
    nodejs_22
    bun
    starship
    direnv
    ripgrep
    fd

    # Theme & Icons
    adwaita-icon-theme
    gnome-themes-extra
    papirus-icon-theme

    # Thunar Plugins
    thunar-archive-plugin
    thunar-volman
  ];

  # Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # XDG
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  # Btop Configuration
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "ayu"; # Mirip Anthropic
      theme_background = false;
      vim_keys = true;
      update_ms = 1000;
    };
  };

  # Bat Configuration
  programs.bat = {
    enable = true;
    config = {
      theme = "base16";
      italic-text = "always";
    };
  };

  # Direnv Configuration
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableFishIntegration = true;
  };

  # Hyprlock Configuration (Declarative)
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = false;
        hide_cursor = true;
        grace = 0;
        no_fade_in = false;
      };
      background = [{
        monitor = "";
        path = "screenshot";
        blur_passes = 3;
        blur_size = 8;
        brightness = 0.6;
      }];
      label = [
        {
          monitor = "";
          text = "<b>$TIME</b>";
          color = "rgb(faf9f5)";
          font_size = 90;
          font_family = "Poppins Bold";
          position = "0, 80";
          halign = "center";
          valign = "center";
        }
      ];
      input-field = [{
        monitor = "";
        size = "280, 50";
        outline_thickness = 2;
        outer_color = "rgb(d97757)";
        inner_color = "rgba(20, 20, 19, 0.8)";
        font_color = "rgb(faf9f5)";
        check_color = "rgb(788c5d)";
        fail_color = "rgb(d97757)";
        placeholder_text = "<i>Password...</i>";
        position = "0, -120";
        halign = "center";
        valign = "center";
      }];
    };
  };

  # Hypridle Configuration (Declarative)
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "brightnessctl -s set 20%";
          on-resume = "brightnessctl -r";
        }
        {
          timeout = 480;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 600;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  # Wofi Configuration
  programs.wofi = {
    enable = true;
    settings = {
      allow_images = true;
      width = "30%";
      lines = 10;
      location = "center";
      prompt = "Search Apps...";
      filter_rate = 100;
    };
  };

  # Kitty Terminal Configuration
programs.kitty = {
  enable = true;
  font = {
    name = "JetBrainsMono Nerd Font";
    size = 11;
  };
  settings = {
    confirm_os_window_close = 0;
    background_opacity = "0.85";
    window_padding_width = 12;
    scrollback_lines = 10000;
    enable_audio_bell = "no";

    # Anthropic Colors
    foreground = "#faf9f5";
    background = "#141413";
    selection_background = "#d97757";
    selection_foreground = "#141413";
    url_color = "#6a9bcc";

    # Cursor
    cursor = "#d97757";
    cursor_text_color = "#141413";
  };
};
# ─── Home File (Deploy dotfiles) ──────────────────
# Hyprpaper — wallpaper config
home.file.".config/hypr/hyprpaper.conf".source = ../configs/hypr/hyprpaper.conf;

# Waybar — fallback panel
home.file.".config/waybar/config".source = ../configs/waybar/config.jsonc;
home.file.".config/waybar/style.css".source = ../configs/waybar/style.css;

# Fastfetch
home.file.".config/fastfetch/config.jsonc".source = ../configs/fastfetch/config.jsonc;

# Fuzzel App Launcher Config
home.file.".config/fuzzel/fuzzel.ini".text = ''
  [main]
  font=JetBrainsMono Nerd Font:size=11
  icon-theme=Papirus-Dark
  terminal=kitty
  lines=10
  width=35
  horizontal-pad=12
  vertical-pad=8
  inner-pad=4

  [colors]
  background=141413ff
  text=faf9f5ff
  match=d97757ff
  selection=d9775722
  selection-text=faf9f5ff
  selection-match=d97757ff
  border=d97757ff

  [border]
  width=2
  radius=10
'';

# Auto-clone cartoon-shell on first activation
home.activation.cloneCartoonShell = lib.hm.dag.entryAfter ["writeBoundary"] ''
  CARTOON_SHELL_DIR="$HOME/.config/quickshell/cartoon-shell"
  if [ ! -d "$CARTOON_SHELL_DIR" ]; then
    $DRY_RUN_CMD ${pkgs.git}/bin/git clone \
      https://github.com/mailong2401/cartoon-shell.git \
      "$CARTOON_SHELL_DIR"
    echo "cartoon-shell cloned to $CARTOON_SHELL_DIR"
  else
    echo "cartoon-shell already exists at $CARTOON_SHELL_DIR, skipping clone."
  fi
'';

# Kitty Terminal Configuration
# Fish Shell Configuration
programs.fish = {
  enable = true;
  interactiveShellInit = ''
    set fish_greeting # Matikan greeting default
    starship init fish | source
    zoxide init fish | source
    direnv hook fish | source
  '';
  shellAliases = {
    ls = "eza --icons --group-directories-first";
    ll = "eza -l --icons --group-directories-first";
    la = "eza -la --icons --group-directories-first";
    cat = "bat";
    cd = "z";
    ".." = "cd ..";
    update = "nh os switch /home/juang/Pictures/hyprland/hyprland-claude";
    clean = "nh clean all";
    fetch = "fastfetch --config config.jsonc";
    btop = "btop --utf-force";
  };
};

# Dunst Configuration
services.dunst = {
  enable = true;
  settings = {
    global = {
      width = 320;
      height = 200;
      origin = "top-right";
      offset = "12x48";
      frame_width = 2;
      frame_color = "#d97757";
      corner_radius = 10;
      font = "Poppins 11";
      background = "#141413";
      foreground = "#faf9f5";
    };
    urgency_low = {
      background = "#141413";
      foreground = "#b0aea5";
    };
    urgency_normal = {
      background = "#141413";
      foreground = "#faf9f5";
    };
    urgency_critical = {
      background = "#1a0e0a";
      foreground = "#faf9f5";
      frame_color = "#d97757";
    };
  };
};

# GTK Theme Configuration
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };

  # Starship Prompt
  programs.starship = {
    enable = true;
    enableFishIntegration = true; # Karena lo pake fish
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };

  # Hyprland Configuration via Home Manager
  wayland.windowManager.hyprland = {
    enable = true;
    # package = inputs.hyprland.packages.${pkgs.system}.hyprland; # Matikan ini biar gak rebuild
    # plugins = [
    #   inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars
    #   inputs.hyprland-plugins.packages.${pkgs.system}.hyprexpo
    # ];
    
    extraConfig = builtins.readFile ../configs/hypr/hyprland.conf;
  };

  # Firefox
  programs.firefox.enable = true;
  
  # Environment Variables
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
  };

  programs.home-manager.enable = true;
}
