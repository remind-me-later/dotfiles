{ ... }:

{
  imports = [ ../modules/rice/home.nix ];

  home.username = "maurizio";
  home.homeDirectory = "/home/maurizio";

  programs.gh = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.firefox = {
    enable = true;
    # the existing profile (look in modules/rice/home.nix)
    profiles.default = {
      path = "fmoz1v8i.default";
      isDefault = true;
    };
    # Enterprise policies (see about:policies). Extensions come from
    # addons.mozilla.org and update themselves; removing one here uninstalls it.
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DontCheckDefaultBrowser = true;
      FirefoxHome = {
        SponsoredTopSites = false;
        SponsoredPocket = false;
      };
      FirefoxSuggest = {
        SponsoredSuggestions = false;
        ImproveSuggest = false;
      };
      UserMessaging = {
        ExtensionRecommendations = false;
        FeatureRecommendations = false;
        MoreFromMozilla = false;
        SkipOnboarding = true;
      };
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
          private_browsing = true;
        };
      };
    };
  };

  # Default apps (~/.config/mimeapps.list, now read-only)
  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      let
        firefox = "firefox.desktop";
      in
      {
        "x-scheme-handler/http" = firefox;
        "x-scheme-handler/https" = firefox;
        "text/html" = firefox;
        "application/xhtml+xml" = firefox;
        "application/pdf" = firefox;
        # written by claude-code into ~/.local/share/applications, for login links
        "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
      };
  };

  programs.claude-code = {
    enable = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Ricardo Maurizio Paul";
        email = "memaurifu14@gmail.com";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  programs.htop = {
    enable = true;
  };

  programs.tmux = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.home-manager.enable = true;
  home.stateVersion = "26.05";
}
