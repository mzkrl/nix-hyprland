{ inputs, pkgs, lib, config, ... }: {
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];

  home.username = "juang";
  home.homeDirectory = "/home/juang";
  home.stateVersion = "25.11";

  # Caelestia Shell Configuration (full feature set)
  programs.caelestia = {
    enable = true;
    # with-cli so `caelestia shell <ipc>` works from the shell service too
    package = inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.with-cli;
    cli = {
      enable = true; # Add `caelestia` CLI to PATH (wallpaper, screenshot, clipboard, emoji, shell IPC)
      # Written to ~/.config/caelestia/cli.json (CLI config) — read by `caelestia record`
      settings = {
        # No VAAPI/NVENC encoder available on this GPU stack — fall back to CPU encoding
        record = {
          extraArgs = [ "-fallback-cpu-encoding" "yes" ];
        };
      };
    };
    settings = {
      services = {
        useFahrenheit = false;
        useFahrenheitPerformance = false;
      };
      background = {
        enabled = true;        # Caelestia handles the wallpaper itself
        wallpaperEnabled = true;
      };
      paths = {
        wallpaperDir = "~/Pictures/Wallpapers";
      };
      general = {
        apps = {
          terminal = [ "kitty" ];
          audio = [ "pavucontrol" ];
          playback = [ "mpv" ];
          explorer = [ "thunar" ];
        };
        # Idle management handled natively by Caelestia (replaces hypridle)
        idle = {
          lockBeforeSleep = true;
          inhibitWhenAudio = true;
          timeouts = [
            { timeout = 300; idleAction = [ "brightnessctl" "-s" "set" "20%" ]; returnAction = [ "brightnessctl" "-r" ]; }
            { timeout = 480; idleAction = "lock"; }
            { timeout = 900; idleAction = [ "systemctl" "suspend-then-hibernate" ]; }
          ];
        };
      };
      bar = {
        persistent = true;
        clock = {
          showDate = true;
          showIcon = true;
        };
        statusIcons = [
          { id = "lockStatus"; enabled = true; }
          { id = "audio"; enabled = true; }
          { id = "microphone"; enabled = false; }
          { id = "kbLayout"; enabled = false; }
          { id = "network"; enabled = true; }
          { id = "bluetooth"; enabled = true; }
          { id = "battery"; enabled = true; }
        ];
      };
      # No VAAPI/NVENC encoder available on this GPU stack — fall back to CPU encoding
      # (NB: `record.extraArgs` belongs in `cli.settings` for `caelestia record`, not here)
      launcher = {
        enableDangerousActions = true;
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
          { name = "Settings"; icon = "settings"; description = "Configure the shell"; command = [ "caelestia" "shell" "nexus" "open" ]; enabled = true; dangerous = false; }
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
    # --- Desktop Ricing & Compositor ---
    # Hyprland uses Caelestia Shell for the bar/launcher/nexus/notifs/lock/idle by default.
    # swaybg / swaync / hyprlock / hypridle / wofi are replaced by Caelestia's own modules.
    gpu-screen-recorder  # `caelestia record`
    mpv                  # Video playback (Caelestia launcher `>playback`)
    yt-dlp               # YouTube/streaming for mpv
    fuzzel               # dependency for `caelestia clipboard` & `caelestia emoji`
    kitty                # Terminal

    # --- Clipboard & Screenshot (used by `caelestia`) ---
    wl-clipboard
    cliphist
    grim
    slurp
    swappy
    hyprpicker
    ffmpeg

    # --- Development & CLI Power Tools ---
    nodejs_22
    bun
    zoxide
    fzf
    direnv
    ripgrep
    fd
    starship
    wev                    # Debug keyland events
    lm_sensors

    # --- Nix OS Utilities ---
    nh
    nix-output-monitor
    nvd

    # --- System Themes & Icons ---
    adwaita-icon-theme
    gnome-themes-extra
    papirus-icon-theme

    # --- Ex-Thunar Plugins ---
    thunar-archive-plugin
    thunar-volman
  ];

  # Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withPython3 = false; # Match new HM default (no embedded Python)
    withRuby = false;    # Match new HM default (no embedded Ruby)
  };

  # XDG
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    setSessionVariables = false; # Match new HM default
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

  # Lock & idle management are handled natively by Caelestia Shell:
  #  - Lock screen   -> Caelestia's PAM layer (no hyprlock)
  #  - Idle timeouts -> shell.json `general.idle` (no hypridle)

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
# Caelestia Shell handles notifications/control center — swaync configs removed.

# Wallpaper for Caelestia's wallpaper switcher (launcher `>wallpaper`)
home.file."Pictures/Wallpapers/wallpaper.png".source = ../wallpaper.png;

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

# mpv — minimal themed config
home.file.".config/mpv/mpv.conf".text = ''
  hwdec=auto
  vo=gpu-next
  profile=gpu-hq
  ytdl-format=bestvideo+bestaudio/best
  sub-font="JetBrainsMono Nerd Font"
  sub-color="faf9f5"
  osd-color="faf9f5"
  osd-border-color="141413"
  osd-font="JetBrainsMono Nerd Font"
  volume=60
'';

# Fuzzel — used by `caelestia clipboard` & `caelestia emoji` as the picker UI
home.file.".config/fuzzel/fuzzel.ini" = {
  text = ''
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
  force = true; # overwrite any unmanaged existing fuzzel.ini
};

# HM's GTK module writes these; allow it to claim them even if an unmanaged
# copy already exists
xdg.configFile."gtk-4.0/gtk.css".force = true;
xdg.configFile."gtk-3.0/gtk.css".force = true;

# ─── Caelestia writable configs (so Nexus / CLI can save) ───────────
# HM deploys shell.json & cli.json as read-only store symlinks, which makes
# Nexus ("failed to save config") and `caelestia config set` break. Replace
# them with real writable copies after every switch (Nexus edits then persist
# until the next switch; declarative config wins on rebuild).
home.activation.makeCaelestiaConfigsWritable = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
  for f in shell.json cli.json; do
    target="$HOME/.config/caelestia/$f"
    if [ -L "$target" ]; then
      real="$(readlink -f "$target" || true)"
      if [ -n "$real" ]; then
        rm -f "$target"
        cp -f "$real" "$target"
        chmod 600 "$target"
      fi
    fi
  done
'';
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
    update-safe = "nh os switch /home/juang/Pictures/hyprland/hyprland-claude -- --option min-free 3000000000 --option max-free 5000000000";
    clean = "nh clean all";
    optimise = "nix-store --optimise";
    fetch = "fastfetch --config config.jsonc";
    btop = "btop --force-utf ";
    # Power profiles
    power = "~/.local/bin/power-profile";
    performa = "~/.local/bin/power-profile set performa";
    hemat = "~/.local/bin/power-profile set hemat";
    ultra = "~/.local/bin/power-profile set ultra-hemat";
    # Caelestia utilities
    clip = "caelestia clipboard";
    emoji = "caelestia emoji -p";
    shot = "caelestia screenshot";
    wallpaper = "caelestia wallpaper";
  };
};


# GTK Theme Configuration
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    gtk4.theme = config.gtk.theme; # Keep Adwaita-dark for GTK4 (previously the implicit default)
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3 = {
      extraConfig = {
        # Keep CSD/headerbar dark even when an app ignores the theme variant
        "gtk-application-prefer-dark-theme" = 1;
      };
      # Thunar: force dark headerbar + readable light text (Anthropic palette)
      extraCss = ''
        headerbar, .titlebar, windowheader { background-color: #1d1d1c; color: #faf9f5; }
        headerbar label, headerbar button { color: #faf9f5; }
        window, .background, treeview, list { background-color: #141413; color: #faf9f5; }
        button, entry, menubar, menu, .menu, .context-menu { background-color: #1d1d1c; color: #faf9f5; }
      '';
    };
    gtk4.extraCss = ''
      headerbar, .titlebar { background-color: #1d1d1c; color: #faf9f5; }
      window, .background { background-color: #141413; color: #faf9f5; }
      button, entry { background-color: #1d1d1c; color: #faf9f5; }
    '';
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
    # Pin old format until config is migrated to 0.55's Lua (hyprland.lua).
    # Hyprland upstream will drop hyprlang support in a future release.
    configType = "hyprlang";
  };

  # Startpage
  home.file.".config/startpage/index.html".source = ../configs/startpage/index.html;

  # Default Applications
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "brave-browser.desktop";
      "x-scheme-handler/http" = "brave-browser.desktop";
      "x-scheme-handler/https" = "brave-browser.desktop";
      "x-scheme-handler/about" = "brave-browser.desktop";
      "x-scheme-handler/unknown" = "brave-browser.desktop";
    };
  };
  
  # Environment Variables
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    
    # QML & Qt Rendering Optimizations for Caelestia
    QSG_RENDER_LOOP = "basic";       # Fixes stutter on NVIDIA + Wayland
    QT_QUICK_COMPILER_SKIPPED = "0"; # Force QML AOT compilation if available
    QML_DISABLE_DISK_CACHE = "0";    # Ensure QML disk caching is turned on
  };

  programs.home-manager.enable = true;
}
