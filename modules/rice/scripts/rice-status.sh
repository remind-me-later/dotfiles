# rice-status: a status bar that lives in a fuzzel menu.

## readers ###################################################################

bat_dir=/sys/class/power_supply/BAT0

battery_line() {
	echo "$(<"$bat_dir/capacity")%  $(<"$bat_dir/status")"
}

wifi_line() {
	local dev flags key value ssid="" dbm=""
	for dev in /sys/class/net/*/wireless; do
		dev=${dev%/wireless}
		break
	done
	[[ -d $dev ]] || { echo "no device" && return; }
	# iwd powers the device off (or rfkill blocks it) -> the link goes down
	flags=$(<"$dev/flags")
	if ((! (flags & 1))); then
		echo "off"
		return
	fi
	while read -r key value; do
		case $key in
		SSID:) ssid=$value ;;
		signal:) dbm=${value%% *} ;;
		esac
	done < <(iw dev "${dev##*/}" link)
	if [[ -z $ssid ]]; then
		echo "disconnected"
		return
	fi
	# dBm -> % the way NetworkManager did it: -100 is 0%, -50 and up is 100%
	local pct=$((2 * (dbm + 100)))
	((pct > 100)) && pct=100
	((pct < 0)) && pct=0
	echo "$ssid  $pct%"
}

volume_line() {
	wpctl get-volume @DEFAULT_AUDIO_SINK@ |
		awk '{ printf "%d%%%s\n", $2 * 100 + 0.5, ($3 ? "  muted" : "") }'
}

light_line() { brightnessctl -m | cut -d, -f4; }

## main ######################################################################

printf '%-8s %s\n' \
	time "$(date '+%H:%M  %a %d %b')" \
	battery "$(battery_line)" \
	wifi "$(wifi_line)" \
	volume "$(volume_line)" \
	light "$(light_line)" |
	fuzzel --dmenu --minimal-lines --prompt "" || true
