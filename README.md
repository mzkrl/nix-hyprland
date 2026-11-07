# nix-hyprland

This is the complete configuration of one NixOS laptop: the kernel parameters, the login screen, the compositor, the shell, the cursor, and the alias that makes `update` do what it says. Everything is declared in a flake, so the machine can be rebuilt from this repository and a bit of patience, which is the whole appeal of Nix and also its main hobby.

The desktop is Hyprland with [Caelestia Shell](https://github.com/caelestia-dots/shell) doing the heavy lifting. Caelestia supplies the bar, launcher, dashboard, notifications, lock screen, idle handling, wallpaper, and a control center called Nexus, which retired a small crowd of separate programs (swaync, hypridle, hyprlock, and friends) in one go. The colours come from a warm charcoal-and-orange palette, applied consistently enough that even the terminal, launcher and window borders look like they were introduced to each other.

The setup is built around a hybrid Intel and NVIDIA laptop, and it shows. If your machine is the same shape, most of this will transplant cleanly. If not, you will still find plenty to borrow, and the section on making it yours lists what to change.

## What is inside

| Area | Choice |
| --- | --- |
| Base | NixOS 26.05 (`nixos-26.05`), flakes, Home Manager `release-26.05` |
| Compositor | Hyprland, configured in classic hyprlang syntax |
| Shell | Caelestia Shell with its CLI (`caelestia`) |
| Login | greetd with tuigreet |
| Terminal and shell | Kitty, fish, Starship, zoxide, direnv |
| Editor | Neovim |
| Browser | Brave, plus a wrapper that keeps hardware video decode from misbehaving (see below) |
| Files and media | Thunar, mpv, yt-dlp |
| Graphics | Intel iGPU for the desktop, NVIDIA proprietary driver with PRIME offload |
| Audio | PipeWire with PulseAudio, ALSA and JACK compatibility |
| Theme | Adwaita-dark, Papirus-Dark icons, a custom `kanade` cursor theme, JetBrainsMono Nerd Font |
| Housekeeping | `nh`, `nix-output-monitor`, `nvd`, automatic store optimisation and garbage collection |

Some smaller touches are worth a mention. The display runs at 10-bit colour with Hyprland's colour management enabled, so HDR content can pass through. Kitty swallows the programs launched from it. The bar is persistent, idle handling dims the screen, then locks, then suspends, and the lid switch locks the session on close.

## Hardware assumptions

The configuration was written for a laptop with an Intel iGPU, an NVIDIA RTX 2050, UEFI boot, and a dual-boot arrangement with Windows and Ubuntu. Several files reflect that directly:

- `nixos/configuration.nix` sets the PRIME bus IDs (`PCI:0:2:0` for Intel, `PCI:1:0:0` for NVIDIA), forces the SOF audio driver for the Intel audio hardware, and loads early modules for the touchpad and sound.
- The bootloader is GRUB in EFI mode with os-prober, so other operating systems show up in the menu.
- Two extra filesystems, `/mnt/windows` (NTFS) and `/mnt/ubuntu` (ext4), are mounted by UUID.
- The `nvidia-offload` command is installed system-wide for sending a program to the discrete GPU.

## Making it yours

Nothing here is difficult, but a few values are personal and need replacing before a first build. Two `grep` commands find most of them.

1. **Clone the repository** somewhere you will keep it.

   ```bash
   git clone https://github.com/mzkrl/nix-hyprland.git
   cd nix-hyprland
   ```

2. **Generate your own hardware configuration.** The one in the repository describes someone else's disks.

   ```bash
   sudo nixos-generate-config --show-hardware-config > nixos/hardware-configuration.nix
   ```

3. **Replace the username.** The user is called `juang`, and the name appears in several places. Run `grep -rn juang .` to see them all. The main ones are `users.users.juang` and the greetd session user in `nixos/configuration.nix`, `home-manager.users.juang` in `flake.nix`, and the username, home directory, launcher entries and aliases in `home/default.nix`.

4. **Replace the checkout path.** The repository is expected to live at `/home/juang/Pictures/hyprland/hyprland-claude`, and that path is written into `programs.nh.flake`, the `update` aliases, the wallpaper command in `hyprland.conf`, and the line at the top of `hyprland.conf` that sources `theme.conf`. `grep -rn hyprland-claude .` finds them.

5. **Check the GPU section.** Run `lspci | grep -E "VGA|3D"` and compare the bus IDs against the ones in `nixos/configuration.nix`. Without an NVIDIA GPU, remove the `hardware.nvidia` block and the NVIDIA environment variables in `configuration.nix`, `home/default.nix` and `hyprland.conf`.

6. **Deal with the extra mounts.** The `/mnt/windows` and `/mnt/ubuntu` entries use UUIDs from the original machine. A filesystem that does not exist can stall the boot, so delete these entries or point them at your own partitions. Adding `nofail` to the options is a kind precaution.

7. **Choose a bootloader.** GRUB with os-prober suits a dual-boot machine. On a single-OS system, systemd-boot is simpler.

8. **Build.** The flake output is named `nixos`, matching the hostname.

   ```bash
   sudo nixos-rebuild switch --flake .#nixos
   ```

   Once the system is up, `nh os switch` (or the `update` alias) takes over.

Timezone (`Asia/Jakarta`), locale and keyboard layout live in the same file and are easy to change.

## Daily use

### Shell aliases

These are defined in `home/default.nix` for fish.

| Alias | What it does |
| --- | --- |
| `update` | Rebuilds the system with `nh os switch` |
| `update-safe` | The same rebuild, with tighter free-space limits for when the disk is nervous |
| `clean` | `nh clean all`, which removes old generations |
| `optimise` | Deduplicates the Nix store |
| `ls`, `ll`, `la` | `eza` with icons and directories first |
| `cat` | `bat` |
| `cd` | `zoxide`, so `cd proj` goes where you meant |
| `fetch` | Fastfetch with the custom config |
| `power`, `performa`, `hemat`, `ultra` | Power profile controls (next section) |
| `clip`, `emoji`, `shot`, `wallpaper` | Shortcuts to the matching `caelestia` subcommands |

### Power profiles

`scripts/power-profile.sh` is installed as `~/.local/bin/power-profile` and offers four modes. Each one sets the system power profile through power-profiles-daemon, adjusts Hyprland's animations, blur and shadows to match, and decides what the NVIDIA GPU is allowed to do. The notifications are partly in Indonesian, as the mode names suggest.

| Mode | CPU | Effects | NVIDIA GPU |
| --- | --- | --- | --- |
| `performa` | performance | full | on |
| `balance` | balanced | full | on (offload) |
| `hemat` | power-saver | reduced shadows | on |
| `ultra-hemat` | power-saver | animations and blur off | off |

`power-profile cycle` steps through the modes, `power-profile menu` opens a picker, and `power-profile get` reports the current one. The same four modes also appear in the Caelestia launcher. The GPU switching uses `sudo` to write to sysfs and unload the NVIDIA kernel modules, so expect it to want your privileges.

### Keybindings

`SUPER` is the main modifier. The complete list is in `configs/hypr/hyprland.conf`, and the ones below cover most days.

| Keys | Action |
| --- | --- |
| `SUPER + Q` | Terminal (add `ALT` to run it on the NVIDIA GPU) |
| `SUPER + B` | Browser (add `ALT` for the NVIDIA GPU) |
| `SUPER + E` | File manager |
| `SUPER + R` | Caelestia launcher |
| `SUPER + D` | Dashboard |
| `SUPER + SHIFT + D` | Sidebar |
| `SUPER + N` | Nexus control center |
| `SUPER + M` | Session menu (logout, reboot, shutdown) |
| `SUPER + C` | Close window |
| `SUPER + V` | Toggle floating |
| `SUPER + F` / `SUPER + SHIFT + F` | Fullscreen / maximise |
| `SUPER + T` | Pin window |
| `SUPER + G` | Toggle window group |
| `SUPER + H J K L` | Move focus |
| `SUPER + SHIFT + H J K L` | Swap windows |
| `SUPER + ALT + H J K L` | Resize windows |
| `SUPER + 1` to `0` | Go to workspace |
| `SUPER + SHIFT + 1` to `0` | Send window to workspace |
| `SUPER + CTRL + ← →` or `SUPER + [ ]` | Previous and next workspace |
| `SUPER + S` | Scratchpad workspace |
| `SUPER + grave` (the key above Tab) | Clipboard history |
| `SUPER + SHIFT + grave` | Emoji picker |
| `SUPER + SHIFT + P` | Colour picker |
| `Print` / `SHIFT + Print` / `CTRL + Print` | Screenshot: full screen, region, region to clipboard |
| `SUPER + SHIFT + R` / `SUPER + SHIFT + E` | Screen recording, without and with audio |
| `SUPER + F5` / `SUPER + SHIFT + F5` | Cycle power profile / open the profile menu |
| `SUPER + CTRL + SHIFT + R` | Restart Caelestia Shell |
| `ALT + Tab` | Cycle windows |
| `SUPER + mouse` | Left button moves, right button resizes |

Volume, brightness and media keys work as expected, and Caelestia draws the on-screen display for them.

## Quirks worth knowing about

- **Two bindings share `SUPER + L`.** It is bound both to "focus right" and to the Caelestia lock screen. Hyprland accepts both without complaint, which makes the outcome a matter of suspense. `CTRL + ALT + L` locks unambiguously.
- **Brave is wrapped.** Video is decoded on the NVIDIA GPU while Brave renders on the Intel one, and the hand-off between them produced a flood of EGL errors and glitchy playback. The wrapper in `home/default.nix` turns off accelerated video decode, and the glitches went with it.
- **Caelestia config is writable on purpose.** Home Manager normally links `shell.json` and `cli.json` as read-only files, which stops Nexus from saving anything. A small activation script swaps the links for real copies after each switch. Edits made in Nexus persist until the next rebuild, at which point the declarative config wins.
- **Hyprland config is pinned to hyprlang.** Upstream is moving toward Lua configuration, and `configType = "hyprlang"` keeps the current file working until this repository migrates.
- **`scripts/apply.sh` is retired.** It predates `nh`, and the `update` alias replaced it.

## Layout

```
.
├── flake.nix                       # inputs (nixpkgs, home-manager, caelestia-shell) and the nixos output
├── flake.lock
├── nixos/
│   ├── configuration.nix           # system: boot, NVIDIA, audio, greetd, fonts, packages
│   └── hardware-configuration.nix  # generated per machine
├── home/
│   └── default.nix                 # user: Caelestia settings, terminal, fish, GTK, dotfiles
├── configs/
│   ├── hypr/
│   │   ├── hyprland.conf           # binds, rules, input, environment
│   │   └── theme.conf              # palette, borders, blur, animations
│   └── fastfetch/config.jsonc
├── scripts/
│   ├── power-profile.sh            # the four power modes
│   └── apply.sh                    # legacy rebuild helper
├── assets/kanade/                  # cursor theme
└── wallpaper.png                   # copied to ~/Pictures/Wallpapers on switch
```

## License

MIT. See `LICENSE`. Take whatever is useful, and if something breaks, the boot menu still has the previous generation waiting, which is Nix's way of forgiving you in advance.

## Thanks

To the [NixOS](https://nixos.org/), [Hyprland](https://hyprland.org/) and [Home Manager](https://github.com/nix-community/home-manager) projects, and to the authors of [Caelestia Shell](https://github.com/caelestia-dots/shell), whose work replaced several of this repository's former dependencies.
