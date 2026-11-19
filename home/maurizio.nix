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
