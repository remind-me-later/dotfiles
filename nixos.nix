# System side of the rice: dwl session, scripts, portals, fonts, PAM.
# Imported from /etc/nixos/configuration.nix.
{ lib, pkgs, ... }:

let
  # dwl built from the ./dwl submodule (pinned to v0.9) with our config.h.
  # nixpkgs' recipe is reused but always against wlroots 0.20, which 0.9
  # needs, so it builds the same on stable (dwl 0.8 recipe) and unstable.
  dwl = (pkgs.dwl.override { configH = ./dwl-config.h; }).overrideAttrs (old: {
    version = "0.9";
    src = lib.cleanSource ./dwl;
    buildInputs = map
      (p: if (p.pname or "") == "wlroots" then pkgs.wlroots_0_20 else p)
      old.buildInputs;
  });

  script = name: runtimeInputs:
    pkgs.writeShellApplication {
      inherit name runtimeInputs;
      text = builtins.readFile ./scripts/${name}.sh;
    };

  rice-status = script "rice-status" (with pkgs; [
    fuzzel networkmanager wireplumber brightnessctl libnotify
    util-linux coreutils gnugrep gawk procps systemd rice-lock
  ]);

  rice-lock = script "rice-lock" (with pkgs; [ procps coreutils ]);

  rice-wallpaper = script "rice-wallpaper" (with pkgs; [ swaybg procps util-linux coreutils ]);

  rice-batwatch = script "rice-batwatch" (with pkgs; [ coreutils libnotify ]);

  rice-shot = script "rice-shot" (with pkgs; [ grim slurp wl-clipboard libnotify coreutils ]);

  rice-startup = script "rice-startup" (with pkgs; [
    dbus mako swayidle brightnessctl systemd rice-batwatch rice-lock rice-wallpaper
  ]);

  # Started from ~/.profile after logging in on tty1 (see home.nix).
  rice-session = pkgs.writeShellScriptBin "rice-session" ''
    export XDG_CURRENT_DESKTOP=dwl
    export XDG_SESSION_DESKTOP=dwl
    export XDG_SESSION_TYPE=wayland
    export NIXOS_OZONE_WL=1 # Electron/Chromium apps use Wayland
    export RICE_POLKIT_AGENT=${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
    # dwl's (and every app's) stderr goes to the journal: journalctl -t dwl
    if ! ${pkgs.systemd}/bin/systemd-cat -t dwl --stderr-priority=err \
        ${lib.getExe dwl} -s ${lib.getExe rice-startup}; then
      echo "dwl exited with an error, see: journalctl -t dwl -b"
      read -rp "press enter to log out "
    fi
  '';
in
{
  environment.systemPackages = [
    rice-session
    rice-status
    rice-shot
    rice-lock
    rice-wallpaper
    pkgs.wl-clipboard
    pkgs.brightnessctl
    pkgs.adwaita-icon-theme # cursor theme, needed once GNOME is gone
  ];

  # No display manager: log in on the console, ~/.profile starts dwl on tty1.
  # Unlock the keyring with the console login password.
  security.pam.services.login.enableGnomeKeyring = true;

  # Things GNOME (and later greetd) used to turn on for us
  hardware.graphics.enable = true; # mesa: wlroots can't render without it
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [ jetbrains-mono noto-fonts noto-fonts-color-emoji noto-fonts-cjk-sans ];
  services.power-profiles-daemon.enable = true; # powerprofilesctl set power-saver|balanced|performance

  # screen sharing / screenshots via wlr, everything else (file pickers...) via gtk
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.dwl.default = [ "wlr" "gtk" ];
  };

  security.polkit.enable = true;
  # Lock screen: physlock, run through rice-lock (Super+Escape, idle, before sleep).
  # Locking before suspend is done by swayidle -> rice-lock rather than the
  # module's service, so an idle lock + suspend never stacks two physlocks.
  services.physlock = {
    enable = true;
    allowAnyUser = true; # setuid wrapper in /run/wrappers/bin
    lockOn.suspend = false;
    lockOn.hibernate = false;
  };
  services.gnome.gnome-keyring.enable = true;
  programs.dconf.enable = true; # GTK settings (dark theme etc.) live in dconf
}
