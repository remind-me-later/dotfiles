# dotfiles

My NixOS laptop as a flake: system, home-manager apps, and the rice:
dwl (floating), fuzzel, foot, gruvbox dark, JetBrains Mono, rio-style borders, no bar.

## Layout

| Path | What |
|---|---|
| `flake.nix` | inputs (nixpkgs unstable, home-manager), the `nixos` machine, dev shell |
| `hosts/nixos/` | the laptop: boot, network, locale, users, nix settings, hardware scan |
| `home/maurizio.nix` | my apps through home-manager (git, gh, neovim, firefox, ...) |
| `modules/rice/nixos.nix` | builds dwl + scripts, `rice-session`, portals, fonts, lock, ssh agent |
| `modules/rice/home.nix` | bash login, foot, fuzzel, mako, cursor, neovim colors |
| `modules/rice/dwl/` | dwl source, git submodule pinned to `v0.9` |
| `modules/rice/dwl-config.h` | dwl `config.h` (keys, colors, floating default) |
| `modules/rice/patches/` | patches applied to dwl at build time (center new windows) |
| `modules/rice/scripts/` | bash: status menu, lock, wallpaper, battery watcher, screenshots, session startup |

## Use

```sh
git clone --recurse-submodules git@github.com:remind-me-later/dotfiles.git
sudo nixos-rebuild switch --flake ~/Source/dotfiles
nix flake update && sudo nixos-rebuild switch --flake ~/Source/dotfiles   # update everything
```

The machine is picked by hostname (`nixos`). Flakes only see files tracked by
git, so `git add` new files before rebuilding.

There is no display manager: log in on tty1 and `~/.profile` runs `rice-session` (dwl).
Other ttys (`Ctrl+Alt+F2`...) stay plain consoles; quitting dwl logs you out.

`nix develop` (or direnv) gives shfmt, shellcheck and nixfmt, and turns on
`.githooks/pre-commit`, which runs them before every commit.

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
| `Super+l` | status menu (time, battery, wifi, volume, brightness) |
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
git -C modules/rice/dwl fetch --tags && git -C modules/rice/dwl checkout v0.10
# rebase dwl-config.h onto the new dwl/config.def.h, then rebuild
```

nixpkgs' dwl recipe is reused (deps, make flags) with `wlroots` swapped in
`modules/rice/nixos.nix`; a dwl bump usually means bumping that wlroots too (0.9 needs 0.20).

## License

BSD 2-Clause, see `LICENSE`, except the files derived from dwl, which keep
dwl's GPL-3.0 license: `modules/rice/dwl-config.h` (based on dwl's `config.def.h`)
and everything in `modules/rice/patches/`. dwl itself (the submodule) is GPL-3.0.
