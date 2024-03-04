{ pkgs, ... }: {
  programs.foot = {
    enable = true;
    settings = {
      main = {
        term = "foot";
        font = "Cousine Nerd Font Mono:size=16";

        # There is a bug in wlr compositor where foot renders too fast for them
        # https://codeberg.org/dnkl/foot/issues/1133
        # Fixing the window size to ~UHD scaled 1.77777
        include = pkgs.foot.src + "/themes/nord";
      };
      mouse = { hide-when-typing = "yes"; };
      key-bindings = {
        scrollback-up-line = "Control+k";
        scrollback-down-line = "Control+j";
      };
    };
  };
}
