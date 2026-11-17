# rice-startup: run by `dwl -s` once the compositor is up (WAYLAND_DISPLAY is set).
# Everything started here is in dwl's startup process group, so it all
# gets killed when dwl quits.

# Let D-Bus activated services (portals, keyring, ...) find this session.
dbus-update-activation-environment --systemd \
	WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XCURSOR_THEME XCURSOR_SIZE

rice-wallpaper # ~/.config/rice/wallpaper, or flat bg0 if missing
mako &
"$RICE_POLKIT_AGENT" &
rice-batwatch &

# dim after 5 min, lock after 10, suspend after 20; lock before any suspend
swayidle -w \
	timeout 300 'brightnessctl -q -s set 10%' resume 'brightnessctl -q -r' \
	timeout 600 'rice-lock' \
	timeout 1200 'systemctl suspend' \
	before-sleep 'rice-lock' \
	lock 'rice-lock' &

wait
