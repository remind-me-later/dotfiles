# rice-shot: screenshot to ~/Pictures/screenshots and the clipboard.
#   rice-shot        whole screen
#   rice-shot area   drag to select a region

dir="${XDG_PICTURES_DIR:-$HOME/Pictures}/screenshots"
mkdir -p "$dir"
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

case ${1:-} in
area)
	geom=$(slurp) || exit 0
	grim -g "$geom" "$file"
	;;
*) grim "$file" ;;
esac

wl-copy --type image/png <"$file"
notify-send -a rice "screenshot" "${file/#$HOME/\~}"
