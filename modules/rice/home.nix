# User side of the rice: bash login, foot, fuzzel, mako in gruvbox + JetBrains Mono, cursor.
# Imported from home/maurizio.nix.
{ pkgs, ... }:

let
  # gruvbox dark
  c = {
    bg0 = "282828";
    bg1 = "3c3836";
    bg2 = "504945";
    bg3 = "665c54";
    fg = "ebdbb2";
    fg4 = "a89984";
    gray = "928374";
    red = "cc241d";
    green = "98971a";
    yellow = "d79921";
    blue = "458588";
    purple = "b16286";
    aqua = "689d6a";
    orange = "d65d0e";
    bred = "fb4934";
    bgreen = "b8bb26";
    byellow = "fabd2f";
    bblue = "83a598";
    bpurple = "d3869b";
    baqua = "8ec07c";
    bfg = "fbf1c7";
  };
  font = "JetBrains Mono";
in
{
  # Dark mode for GTK and portal-aware apps (Firefox...), read via the gtk portal
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  # Cursor. dwl loads the theme named "default" (not $XCURSOR_THEME), so this
  # also creates icons/default -> Adwaita; without it wlroots falls back to a
  # tiny built-in cursor that doesn't scale. Also sets XCURSOR_* and GTK's cursor.
  home.pointerCursor = {
    enable = true;
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24; # dwl scales it with the output (130% on the laptop)
    gtk.enable = true;
  };

  # Login on tty1 starts the dwl session; other ttys stay plain consoles.
  # When dwl quits you're logged out back to the login prompt.
  programs.bash = {
    enable = true;
    profileExtra = ''
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
        exec rice-session
      fi
    '';
    initExtra = ''
      PS1='$ '
    '';
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "${font}:size=14";
        pad = "24x16 center"; # inner border around the text
        initial-window-size-chars = "80x24";
      };
      colors-dark = {
        background = c.bg0;
        foreground = c.fg;
        cursor = "${c.bg0} ${c.fg}";
        selection-background = c.bg2;
        selection-foreground = c.fg;
        regular0 = c.bg0;
        regular1 = c.red;
        regular2 = c.green;
        regular3 = c.yellow;
        regular4 = c.blue;
        regular5 = c.purple;
        regular6 = c.aqua;
        regular7 = c.fg4;
        bright0 = c.gray;
        bright1 = c.bred;
        bright2 = c.bgreen;
        bright3 = c.byellow;
        bright4 = c.bblue;
        bright5 = c.bpurple;
        bright6 = c.baqua;
        bright7 = c.fg;
      };
    };
  };

  # Only the look; neovim itself is enabled in home/maurizio.nix.
  programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.gruvbox-nvim;
      type = "lua";
      config = ''
        vim.o.background = "dark"
        vim.cmd.colorscheme("gruvbox")
      '';
    }
  ];

  # Firefox chrome (tabs, toolbar, menus) in gruvbox, square, JetBrains Mono.
  # Page content is untouched; it follows dark mode via dconf.
  programs.firefox.profiles.default = {
    settings = {
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # read userChrome.css
      "browser.compactmode.show" = true;
      "browser.uidensity" = 1; # compact
    };
    userChrome = ''
      * {
        font-family: "${font}" !important;
      }
      :root {
        --toolbox-bgcolor: #${c.bg0} !important;
        --toolbox-bgcolor-inactive: #${c.bg0} !important;
        --toolbox-textcolor: #${c.fg} !important;
        --toolbox-textcolor-inactive: #${c.fg4} !important;
        --lwt-accent-color: #${c.bg0} !important;
        --lwt-text-color: #${c.fg} !important;
        --toolbar-bgcolor: #${c.bg1} !important;
        --toolbar-color: #${c.fg} !important;
        --toolbar-field-background-color: #${c.bg0} !important;
        --toolbar-field-color: #${c.fg} !important;
        --toolbar-field-focus-background-color: #${c.bg0} !important;
        --toolbar-field-focus-color: #${c.fg} !important;
        --toolbar-field-border-color: #${c.bg3} !important;
        --toolbar-field-focus-border-color: #${c.fg} !important;
        --focus-outline-color: #${c.fg} !important;
        --tab-selected-bgcolor: #${c.bg1} !important;
        --tab-selected-textcolor: #${c.fg} !important;
        --tab-hover-background-color: #${c.bg2} !important;
        --toolbarbutton-hover-background: #${c.bg2} !important;
        --toolbarbutton-active-background: #${c.bg3} !important;
        --arrowpanel-background: #${c.bg0} !important;
        --arrowpanel-color: #${c.fg} !important;
        --arrowpanel-border-color: #${c.fg} !important;
        --panel-separator-color: #${c.bg3} !important;
        --urlbarView-highlight-background: #${c.bg2} !important;
        --urlbarView-highlight-color: #${c.fg} !important;
        --sidebar-background-color: #${c.bg0} !important;
        --sidebar-text-color: #${c.fg} !important;
        --chrome-content-separator-color: #${c.bg3} !important;
        /* square everything */
        --border-radius-small: 0 !important;
        --border-radius-medium: 0 !important;
        --border-radius-large: 0 !important;
        --tab-border-radius: 0 !important;
        --toolbarbutton-border-radius: 0 !important;
        --arrowpanel-border-radius: 0 !important;
      }
      .tab-background,
      #urlbar-background,
      #searchbar {
        border-radius: 0 !important;
      }
      /* the selected tab gets a cream edge, like a focused window */
      .tabbrowser-tab[selected] .tab-background {
        box-shadow: inset 0 -2px 0 #${c.fg} !important;
      }
    '';
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "${font}:size=14";
        terminal = "foot";
        prompt = "''";
        icons-enabled = "no";
        width = 44;
        lines = 12;
        horizontal-pad = 24;
        vertical-pad = 16;
        inner-pad = 12; # gap between the prompt and the list
        layer = "overlay";
      };
      colors = {
        background = "${c.bg0}ff";
        text = "${c.fg}ff";
        prompt = "${c.yellow}ff";
        input = "${c.fg}ff";
        placeholder = "${c.gray}ff";
        match = "${c.byellow}ff";
        selection = "${c.bg2}ff";
        selection-text = "${c.fg}ff";
        selection-match = "${c.byellow}ff";
        counter = "${c.gray}ff";
        border = "${c.fg}ff";
      };
      border = {
        width = 4;
        radius = 0;
      };
    };
  };

  # mako is started by the dwl session (rice-startup), only its config lives here
  xdg.configFile."mako/config".text = ''
    font=${font} 14
    background-color=#${c.bg0}
    text-color=#${c.fg}
    border-color=#${c.fg}
    progress-color=over #${c.bg2}
    border-size=4
    border-radius=0
    padding=16
    margin=12
    width=440
    default-timeout=5000
    layer=overlay

    [urgency=low]
    border-color=#${c.bg3}

    [urgency=critical]
    border-color=#${c.bred}
    default-timeout=0
  '';
}
