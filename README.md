# dotfiles

My NixOS laptop as a flake. dwl (floating), fuzzel, foot, gruvbox, no bar.

- `hosts/nixos/`: the machine
- `home/maurizio.nix`: apps
- `modules/rice/`: dwl (submodule, config, patches), scripts, theming

```sh
git clone --recurse-submodules git@github.com:remind-me-later/dotfiles.git
sudo nixos-rebuild switch --flake ~/Source/dotfiles
nix flake update   # then rebuild
```

Log in on tty1 to start dwl. Wallpaper: `rice-wallpaper IMAGE`.

## Keys

| Key | Action |
|---|---|
| `Super+Return` / `Super+p` | foot / launcher |
| `Super+l` | status |
| `Super+Escape` | lock |
| `Super+drag` / `Super+Shift+drag` | move / resize |
| `Super+Shift+c` / `Super+Shift+q` | close / quit |
| `Print` / `Shift+Print` | screenshot / area |

The rest are dwl's defaults, see `modules/rice/dwl-config.h`.

## License

BSD 2-Clause, except `modules/rice/dwl-config.h` and `modules/rice/patches/`,
which are GPL-3.0 like dwl.
