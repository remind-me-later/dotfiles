# rice-status: a status bar that lives in a fuzzel menu.

menu() {
	fuzzel --dmenu --minimal-lines --prompt ""
}

## readers ###################################################################

bat_dir=/sys/class/power_supply/BAT0

battery_line() {
	[[ -d $bat_dir ]] || {
		echo "no battery"
		return
	}
	local cap status now full rate left=""
	cap=$(<"$bat_dir/capacity")
	status=$(<"$bat_dir/status")
	# this battery reports charge_*/current_now; some report energy_*/power_now
	if [[ -r $bat_dir/charge_now ]]; then
		now=$(<"$bat_dir/charge_now") full=$(<"$bat_dir/charge_full") rate=$(<"$bat_dir/current_now")
	else
		now=$(<"$bat_dir/energy_now") full=$(<"$bat_dir/energy_full") rate=$(<"$bat_dir/power_now")
	fi
	if ((rate > 0)); then
		local secs=0
		case $status in
		Discharging) secs=$((now * 3600 / rate)) ;;
		Charging) secs=$(((full - now) * 3600 / rate)) ;;
		esac
		((secs > 0)) && left=$(printf '  %dh%02dm' $((secs / 3600)) $((secs % 3600 / 60)))
	fi
	echo "${cap}%  ${status,,}${left}"
}

wifi_line() {
	if [[ $(nmcli radio wifi) != enabled ]]; then
		echo "off"
		return
	fi
	local line signal ssid
	# -t escapes ':' inside fields as '\:'
	line=$(nmcli -t -f IN-USE,SIGNAL,SSID device wifi list --rescan no | grep -m1 '^\*:') || {
		echo "disconnected"
		return
	}
	line=${line#*:}
	signal=${line%%:*}
	ssid=${line#*:}
	echo "${ssid//\\:/:}  ${signal}%"
}

volume_line() {
	# "Volume: 0.45" or "Volume: 0.45 [MUTED]"
	local out vol
	out=$(wpctl get-volume @DEFAULT_AUDIO_SINK@) || {
		echo "?"
		return
	}
	vol=$(awk '{printf "%d", $2 * 100 + 0.5}' <<<"$out")
	[[ $out == *MUTED* ]] && echo "${vol}%  muted" || echo "${vol}%"
}

light_line() { brightnessctl -m | cut -d, -f4; }

## main ######################################################################

printf '%-8s %s\n' \
	time "$(date '+%H:%M  %a %d %b')" \
	battery "$(battery_line)" \
	wifi "$(wifi_line)" \
	volume "$(volume_line)" \
	light "$(light_line)" |
	menu || true # Escape makes fuzzel exit 1
