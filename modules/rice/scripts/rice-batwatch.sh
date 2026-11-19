# rice-batwatch: no bar, so warn with a notification when the battery runs low.

bat=/sys/class/power_supply/BAT0
low=15
critical=5
warned=0

[[ -d $bat ]] || exit 0

while sleep 60; do
	cap=$(<"$bat/capacity")
	status=$(<"$bat/status")

	if [[ $status != Discharging ]]; then
		warned=0
	elif ((cap <= critical && warned < 2)); then
		notify-send -a rice -u critical "battery critical: ${cap}%" "plug in now"
		warned=2
	elif ((cap <= low && warned < 1)); then
		notify-send -a rice -u critical "battery low: ${cap}%" "plug in soon"
		warned=1
	fi
done
