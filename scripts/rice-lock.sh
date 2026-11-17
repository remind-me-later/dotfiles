# rice-lock: lock with physlock. Switches to a text console and blocks VT
# switching and SysRq until you type your password.

# already locked (e.g. idle lock, then suspend): don't stack a second one
pgrep -x physlock >/dev/null && exit 0

# -d detach (so swayidle/suspend don't wait), -m mute kernel messages, -s disable SysRq
exec /run/wrappers/bin/physlock -d -m -s -p "locked  $(date '+%H:%M  %a %d %b')"
