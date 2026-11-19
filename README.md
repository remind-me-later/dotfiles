# rice

dwl (floating), fuzzel, foot. gruvbox dark, JetBrains Mono, rio-style borders, no bar.

## Layout

| Path | What |
|---|---|
| `dwl/` | dwl source, git submodule pinned to `v0.9` |
| `dwl-config.h` | dwl `config.h` (keys, colors, floating default) |
| `scripts/` | bash: status menu, lock, wallpaper, battery watcher, screenshots, session startup |
| `nixos.nix` | system module: builds dwl + scripts, rice-session, portals, fonts, PAM |
| `home.nix` | home-manager module: bash profile, foot, fuzzel, mako config |

## Install

In `/etc/nixos/configuration.nix`:

```nix
imports = [ ./hardware-configuration.nix <home-manager/nixos> /home/maurizio/Source/rice/nixos.nix ];
```

In `/etc/nixos/home.nix`:

```nix
imports = [ /home/maurizio/Source/rice/home.nix ];
```

Then `sudo nixos-rebuild switch`. There is no display manager: log in on tty1 and `~/.profile` runs `rice-session` (dwl). Other ttys (`Ctrl+Alt+F2`...) stay plain consoles; quitting dwl logs you out.

Clone with `git clone --recurse-submodules`, or run `git submodule update --init` after cloning.
If `dwl/` is empty, the build fails.

## Wallpaper

Not in the repo. Put any image at `~/.config/rice/wallpaper` (no extension needed);
without it the background is flat `#282828`. To change it without logging out:

```sh
rice-wallpaper ~/Pictures/new.jpg   # copies it there and reloads swaybg
rice-wallpaper                      # just reload
```

## Keys (Super = mod)

| Key | Action |
|---|---|
| `Super+Return` | foot |
| `Super+p` | fuzzel launcher |
| `Super+l` | status menu (time, battery, wifi → nmtui, volume, brightness, power) |
| `Super+Escape` | lock (physlock: text console, type your password) |
| `Super+1..9` | view tag |
| `Super+Shift+1..9` | move window to tag |
| `Super+Ctrl+1..9` | also show tag |
| `Super+0` | view all tags |
| `Super+Tab` | previous tag |
| `Super+j` / `Super+k` | focus next / previous window |
| `Super+drag` / `Super+Shift+drag` | move / resize window |
| `Super+middle-click` / `Super+Shift+space` | toggle floating |
| `Super+e` | fullscreen |
| `Super+t` / `Super+f` / `Super+m` | tile / float / monocle layout |
| `Super+Shift+c` | close window |
| `Super+Shift+q` or `Ctrl+Alt+Backspace` | quit dwl |
| `Print` / `Shift+Print` | screenshot screen / area → `~/Pictures/screenshots` + clipboard |
| volume / brightness keys, `Super+scroll` | wpctl / brightnessctl |

## Updating dwl

```sh
git -C dwl fetch --tags && git -C dwl checkout v0.10
# rebase dwl-config.h onto the new dwl/config.def.h, then rebuild
```

nixpkgs' dwl recipe is reused (deps, make flags) with `wlroots` swapped in `nixos.nix`; a dwl bump usually means bumping that wlroots too (0.9 needs 0.20).
