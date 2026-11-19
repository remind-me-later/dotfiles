# rice-status: a status bar that lives in a fuzzel menu.

## readers ###################################################################

bat_dir=/sys/class/power_supply/BAT0

battery_line() {
	echo "$(<"$bat_dir/capacity")%  $(<"$bat_dir/status")"
}

wifi_line() {
	if [[ $(nmcli radio wifi) != enabled ]]; then
		echo "off"
		return
	fi
	local in_use signal ssid
	# -t escapes ':' inside fields as '\:'; the last field (ssid) gets the rest
	while IFS=: read -r in_use signal ssid; do
		if [[ $in_use == '*' ]]; then
			echo "${ssid//\\:/:}  ${signal}%"
			return
		fi
	done < <(nmcli -t -f IN-USE,SIGNAL,SSID device wifi list --rescan no)
	echo "disconnected"
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
