# System side of the rice: dwl session, scripts, portals, fonts, PAM.
# Imported from /etc/nixos/configuration.nix.
{ lib, pkgs, ... }:

let
  # dwl built from the ./dwl submodule (pinned to v0.8) with our config.h
  dwl = (pkgs.dwl.override { configH = ./dwl-config.h; }).overrideAttrs (_: {
    src = lib.cleanSource ./dwl;
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

  rice-batwatch = script "rice-batwatch" (with pkgs; [ coreutils libnotify ]);

  rice-shot = script "rice-shot" (with pkgs; [ grim slurp wl-clipboard libnotify coreutils ]);

  rice-startup = script "rice-startup" (with pkgs; [
    dbus swaybg mako swayidle brightnessctl systemd rice-batwatch rice-lock
  ]);

  # Started from ~/.profile after logging in on tty1 (see home.nix).
  rice-session = pkgs.writeShellScriptBin "rice-session" ''
    export XDG_CURRENT_DESKTOP=dwl
    export XDG_SESSION_DESKTOP=dwl
    export XDG_SESSION_TYPE=wayland
    export XCURSOR_THEME=Adwaita
    export XCURSOR_SIZE=24
    export MOZ_ENABLE_WAYLAND=1
    export NIXOS_OZONE_WL=1 # Electron/Chromium apps use Wayland
    export RICE_WALLPAPER=${./wallpaper.jpg}
    export RICE_POLKIT_AGENT=${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
    exec ${lib.getExe dwl} -s ${lib.getExe rice-startup}
  '';
in
{
  environment.systemPackages = [
    rice-session
    rice-status
    rice-shot
    rice-lock
    pkgs.wl-clipboard
    pkgs.brightnessctl
    pkgs.libnotify
    pkgs.adwaita-icon-theme # cursor theme, needed once GNOME is gone
  ];

  # No display manager: log in on the console, ~/.profile starts dwl on tty1.
  # Unlock the keyring with the console login password.
  security.pam.services.login.enableGnomeKeyring = true;

  # Things GNOME used to turn on for us
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [ go-font noto-fonts noto-fonts-color-emoji noto-fonts-cjk-sans ];
  services.upower.enable = true; # battery info for apps
  services.power-profiles-daemon.enable = true;
  services.gvfs.enable = true; # trash, network mounts in GTK file dialogs

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
