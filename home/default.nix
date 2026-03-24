{ inputs, pkgs, lib, config, ... }: {
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];

  home.username = "juang";
  home.homeDirectory = "/home/juang";
  home.stateVersion = "25.11";

  # Caelestia Shell Configuration
  programs.caelestia = {
    enable = true;
    package = inputs.caelestia-shell.packages.${pkgs.system}.default;
    settings = {
      services = {
        useFahrenheit = false;
        useFahrenheitPerformance = false;
      };
      background = {
        enabled = false; # Disable Caelestia background layer entirely — swaybg handles wallpaper
      };
      launcher = {
        actions = [
          { name = "Calculator"; icon = "calculate"; description = "Do simple math equations"; command = [ "autocomplete" "calc" ]; enabled = true; dangerous = false; }
          { name = "Scheme"; icon = "palette"; description = "Change the current colour scheme"; command = [ "autocomplete" "scheme" ]; enabled = true; dangerous = false; }
          { name = "Wallpaper"; icon = "image"; description = "Change the current wallpaper"; command = [ "autocomplete" "wallpaper" ]; enabled = true; dangerous = false; }
          { name = "Variant"; icon = "colors"; description = "Change the current scheme variant"; command = [ "autocomplete" "variant" ]; enabled = true; dangerous = false; }
          { name = "Random"; icon = "casino"; description = "Switch to a random wallpaper"; command = [ "caelestia" "wallpaper" "-r" ]; enabled = true; dangerous = false; }
          { name = "Light"; icon = "light_mode"; description = "Change the scheme to light mode"; command = [ "setMode" "light" ]; enabled = true; dangerous = false; }
          { name = "Dark"; icon = "dark_mode"; description = "Change the scheme to dark mode"; command = [ "setMode" "dark" ]; enabled = true; dangerous = false; }
          { name = "Shutdown"; icon = "power_settings_new"; description = "Shutdown the system"; command = [ "systemctl" "poweroff" ]; enabled = true; dangerous = true; }
          { name = "Reboot"; icon = "cached"; description = "Reboot the system"; command = [ "systemctl" "reboot" ]; enabled = true; dangerous = true; }
          { name = "Logout"; icon = "exit_to_app"; description = "Log out of the current session"; command = [ "loginctl" "terminate-user" "" ]; enabled = true; dangerous = true; }
          { name = "Lock"; icon = "lock"; description = "Lock the current session"; command = [ "loginctl" "lock-session" ]; enabled = true; dangerous = false; }
          { name = "Sleep"; icon = "bedtime"; description = "Suspend then hibernate"; command = [ "systemctl" "suspend-then-hibernate" ]; enabled = true; dangerous = false; }
          { name = "Settings"; icon = "settings"; description = "Configure the shell"; command = [ "caelestia" "shell" "controlCenter" "open" ]; enabled = true; dangerous = false; }
          { name = "Mode Performa"; icon = "rocket_launch"; description = "CPU: performance | GPU: ON"; command = [ "/home/juang/.local/bin/power-profile" "set" "performa" ]; enabled = true; dangerous = false; }
          { name = "Mode Balance"; icon = "balance"; description = "CPU: balanced | GPU: ON (offload)"; command = [ "/home/juang/.local/bin/power-profile" "set" "balance" ]; enabled = true; dangerous = false; }
          { name = "Mode Hemat"; icon = "energy_savings_leaf"; description = "CPU: power-saver | GPU: ON (low)"; command = [ "/home/juang/.local/bin/power-profile" "set" "hemat" ]; enabled = true; dangerous = false; }
          { name = "Mode Ultra Hemat"; icon = "battery_saver"; description = "CPU: power-saver | GPU: OFF"; command = [ "/home/juang/.local/bin/power-profile" "set" "ultra-hemat" ]; enabled = true; dangerous = false; }
        ];
      };
    };
  };
  # User specific packages
  home.packages = with pkgs; [
    # Desktop Utilities
    swaybg                 # Wallpaper daemon (hyprpaper has protocol mismatch with Hyprland flake)
    hypridle               # Idle daemon
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
    lm_sensors            # Hardware sensor monitoring (CPU/GPU temp)
    bat                   # cat with wings

    # Apps
    # firefox antigravity discord # udah ada di configuration.nix, biar ga double.

    # Dev & Terminal
    # git
    # gh
    # glab
    # nodejs_22
    # bun #sama kyk diatas
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
      show_gpu_info = "On";       # Show GPU info in the UI
      gpu_mirror_graph = true;     # Mirror GPU graph with CPU graph
      shown_boxes = "cpu mem net proc gpu"; # Show GPU box
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

  # Zoxide Configuration
  programs.zoxide = {
    enable = true;
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
home.file.".config/waybar/config.jsonc".source = ../configs/waybar/config.jsonc;
home.file.".config/waybar/style.css".source = ../configs/waybar/style.css;
home.file.".config/waybar/colors.css".source = ../configs/waybar/colors.css;

# SwayNC — Control Center
home.file.".config/swaync/config.json".source = ../configs/swaync/config.json;
home.file.".config/swaync/style.css".source = ../configs/swaync/style.css;

# Fastfetch
home.file.".config/fastfetch/config.jsonc".source = ../configs/fastfetch/config.jsonc;

# Power Profile Script
home.file.".local/bin/power-profile" = {
  source = ../scripts/power-profile.sh;
  executable = true;
};
home.file.".icons/kanade" = {
  source = ../assets/kanade;
  recursive = true;
};

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

# Kitty Terminal Configuration
# Fish Shell Configuration
programs.fish = {
  enable = true;
  interactiveShellInit = ''
    set fish_greeting # Matikan greeting default
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
    # Power profiles
    power = "~/.local/bin/power-profile";
    performa = "~/.local/bin/power-profile set performa";
    hemat = "~/.local/bin/power-profile set hemat";
    "ultra-hemat" = "~/.local/bin/power-profile set ultra-hemat";
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
#    cursorTheme = {
#      name = "Adwaita";
#      package = pkgs.adwaita-icon-theme;
#    };
     cursorTheme = {
       name = "kanade";
       size = 24;
    };
  };

  # Starship Prompt
  programs.starship = {
    enable = true;
    enableFishIntegration = true; # Karena lo pake fish
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[➜](bold #d97757)";
        error_symbol = "[✗](bold #d97757)";
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

  # Startpage
  home.file.".config/startpage/index.html".source = ../configs/startpage/index.html;

  # Firefox
  programs.firefox = {
    enable = true;
    profiles.juang = {
      isDefault = true;
      userChrome = builtins.readFile ../configs/firefox/userChrome.css;
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.startup.homepage" = "file://${config.home.homeDirectory}/.config/startpage/index.html";
        "browser.newtabpage.enabled" = false;
      };
    };
  };
  
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
