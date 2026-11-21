{ pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./firmware.nix
    ../../modules/rice/nixos.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0; # no menu; hold Space while booting to pick a generation
  boot.loader.systemd-boot.configurationLimit = 10; # keeps the ESP from filling up
  boot.loader.systemd-boot.editor = false; # no `e` -> init=/bin/sh past physlock

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos";
  # Wi-Fi: iwd alone, doing its own DHCP; DNS via systemd-resolved.
  # Connect with: iwctl station wlo1 connect <ssid>
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };
  # DNS: Cloudflare over TLS for everything. The router's DNS (from DHCP via
  # iwd) stays listed, but strict DoT means nothing is ever sent to it in
  # plaintext. Check with: resolvectl status / resolvectl query <name>
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS = [
        "1.1.1.1#cloudflare-dns.com"
        "1.0.0.1#cloudflare-dns.com"
        "2606:4700:4700::1111#cloudflare-dns.com"
        "2606:4700:4700::1001#cloudflare-dns.com"
      ];
      DNSOverTLS = true;
      Domains = [ "~." ]; # prefer these for all names
    };
  };
  # no wired port; dhcpcd would fight iwd over wlo1
  networking.useDHCP = false;
  networking.dhcpcd.enable = false;

  time.timeZone = "Europe/Madrid";
  i18n.defaultLocale = "en_US.UTF-8";

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."maurizio" = {
    isNormalUser = true;
    description = "Maurizio";
    extraGroups = [ "wheel" ]; # wheel may also drive iwd (iwctl)
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05";

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.maurizio = import ../../home/maurizio.nix;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Delete old generations weekly and hard-link identical store files.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.settings.auto-optimise-store = true;

  # For Kani's downloaded CBMC binaries.
  programs.nix-ld.enable = true;

  # Linux (syscalls, libc, man 7 socket...) and POSIX (man 3p ...) manuals
  environment.systemPackages = with pkgs; [
    man-pages
    man-pages-posix
  ];
  # man's default order puts 3p before 2 (`man socket` gave socket(3p));
  # look in the Linux pages first, POSIX last.
  environment.variables.MANSECT = "1:n:l:8:2:3:5:4:9:6:7:0p:1p:3p";

  # nvim is the editor (home/maurizio.nix)
  programs.nano.enable = false;

  # Compressed swap in RAM, used before the disk swap (kept for hibernation)
  zramSwap.enable = true;

  # Firewall rules in nftables (`sudo nft list ruleset`) instead of iptables
  networking.nftables.enable = true;
}
