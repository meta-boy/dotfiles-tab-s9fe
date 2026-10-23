# dotfiles-tab-s9fe

The Linux session on my Galaxy Tab S9 FE: Hyprland on Arch Linux ARM, running in a chroot on stock
Android and shown through Termux:X11. The stack that makes this work is `meta-boy/lindroid-tab-s9fe`.
These are the home-directory files of `root` in `/data/local/arch`.

- **Hyprland:** `.config/hypr/hyprland.lua` (Lua config) uses i3-style keys:
  - Super+Return foot, Super+Space / Super+D the rofi launcher, Super+Tab the window switcher.
  - Super+Shift+Q close, Super+R resize mode, Super+BackSpace Android Back.
  - Super+Shift+E opens a confirm menu (Sleep / Reload config / Cancel); Super+Shift+Escape sleeps at once.
    Sleep freezes the session; a touch, key press or reopening Termux:X11 wakes it.
  - The output mode follows Termux:X11 through `$XDG_RUNTIME_DIR/lindroid-mode`.
- **Colours:** `wallpaper` draws with `awww`, and `matugen` derives the scheme from the image.
  Templates in `.config/matugen/templates` write `colors.lua`, `colors.css`, `colors.rasi`, foot's
  `colors.ini` and mako. Super+Shift+Space opens the picker over `~/Wallpaper`.
- **Bar:** waybar with floating pill modules. Battery comes from the tablet's sysfs, and the
  top-right button opens a rofi status menu.
- **Launcher:** rofi 2.0 (Wayland), built from source by the stack repo's `setup/04-build-rofi.sh`.
  It's a launchpad grid (`config.rasi`), with list menus in `list.rasi` and `menu.rasi`.
- **Terminal:** foot. Linux apps get no GPU here, so kitty through llvmpipe is too slow.
  `.local/bin/app-env` runs any GL app with Mesa llvmpipe instead of the compositor's libhybris env.
- **Also here:** mako, GTK3 (Adwaita-dark, Catppuccin overrides, Papirus), Thunar, fastfetch, zsh with
  oh-my-zsh, and herdr's `config.toml`.
- **Hidden launcher entries:** `.local/share/applications/*.desktop` keeps tool entries out of the
  launcher. The Android app entries (`android.*.desktop`) aren't tracked; `droid-apps-sync` writes them.

## Install

On the tablet, as root in the chroot:

    pacman -S --needed awww matugen git zsh
    git clone git@github.com:meta-boy/dotfiles-tab-s9fe.git /tmp/dots
    cp -a /tmp/dots/. /root/ && rm -rf /root/.git /root/README.md
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

The rest of the packages are in the stack repo's `setup/02-arch-packages.sh`.

## Wallpapers

`~/Wallpaper` ships only the generated `catppuccin-mocha.png`. The two in the screenshots are from
wallhaven; download them into `~/Wallpaper` and pick one with Super+Shift+Space:

- https://wallhaven.cc/w/vpew9p
- https://wallhaven.cc/w/yqkgrk
