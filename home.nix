# User side of the rice: foot, fuzzel, mako, swaylock in gruvbox + Go Mono.
# Imported from /etc/nixos/home.nix.
{ ... }:

let
  # gruvbox dark
  c = {
    bg0 = "282828"; bg1 = "3c3836"; bg2 = "504945"; bg3 = "665c54";
    fg = "ebdbb2"; fg4 = "a89984"; gray = "928374";
    red = "cc241d"; green = "98971a"; yellow = "d79921"; blue = "458588";
    purple = "b16286"; aqua = "689d6a"; orange = "d65d0e";
    bred = "fb4934"; bgreen = "b8bb26"; byellow = "fabd2f"; bblue = "83a598";
    bpurple = "d3869b"; baqua = "8ec07c"; bfg = "fbf1c7";
  };
  font = "Go Mono";
in
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "${font}:size=14";
        pad = "4x4";
      };
      colors-dark = {
        background = c.bg0;
        foreground = c.fg;
        cursor = "${c.bg0} ${c.fg}";
        selection-background = c.bg2;
        selection-foreground = c.fg;
        regular0 = c.bg0; regular1 = c.red; regular2 = c.green; regular3 = c.yellow;
        regular4 = c.blue; regular5 = c.purple; regular6 = c.aqua; regular7 = c.fg4;
        bright0 = c.gray; bright1 = c.bred; bright2 = c.bgreen; bright3 = c.byellow;
        bright4 = c.bblue; bright5 = c.bpurple; bright6 = c.baqua; bright7 = c.fg;
      };
    };
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "${font}:size=14";
        terminal = "foot";
        prompt = "'> '";
        icons-enabled = "no";
        width = 44;
        lines = 12;
        horizontal-pad = 12;
        vertical-pad = 8;
        inner-pad = 6;
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
        border = "${c.yellow}ff";
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
    border-color=#${c.yellow}
    progress-color=over #${c.bg2}
    border-size=4
    border-radius=0
    padding=10
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

  programs.swaylock = {
    enable = true;
    settings = {
      image = "${./wallpaper.jpg}";
      scaling = "fill";
      font = font;
      indicator-radius = 80;
      indicator-thickness = 8;
      show-failed-attempts = true;
      color = c.bg0;
      inside-color = "${c.bg0}dd";
      inside-clear-color = "${c.bg0}dd";
      inside-ver-color = "${c.bg0}dd";
      inside-wrong-color = "${c.bg0}dd";
      ring-color = c.yellow;
      ring-clear-color = c.bg3;
      ring-ver-color = c.bblue;
      ring-wrong-color = c.bred;
      key-hl-color = c.byellow;
      bs-hl-color = c.bred;
      line-color = "00000000";
      line-clear-color = "00000000";
      line-ver-color = "00000000";
      line-wrong-color = "00000000";
      separator-color = "00000000";
      text-color = c.fg;
      text-clear-color = c.fg;
      text-ver-color = c.fg;
      text-wrong-color = c.bred;
    };
  };
}
