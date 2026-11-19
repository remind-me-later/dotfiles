{ pkgs, ... }:

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

  home.packages = [ pkgs.spotify ];

  programs.home-manager.enable = true;
  home.stateVersion = "26.05";
}
