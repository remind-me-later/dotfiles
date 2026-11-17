# rice-wallpaper: (re)start the background.
#   rice-wallpaper          reload ~/.config/rice/wallpaper
#   rice-wallpaper IMAGE    copy IMAGE there first, then reload
# Without a wallpaper file the background is flat gruvbox bg0.

wallpaper="${XDG_CONFIG_HOME:-$HOME/.config}/rice/wallpaper"

if (($# > 0)); then
	mkdir -p "${wallpaper%/*}"
	cp -- "$1" "$wallpaper"
fi

# nixpkgs' swaybg runs as ".swaybg-wrapped", so match the command line instead
pkill -f '^swaybg ' || true

if [[ -f $wallpaper ]]; then
	setsid -f swaybg -i "$wallpaper" -m fill
else
	setsid -f swaybg -c '#282828'
fi
