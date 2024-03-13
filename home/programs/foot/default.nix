{ pkgs, ... }: {
  programs.foot = {
    enable = true;
    settings = {
      main = {
        term = "foot";
        font = "Cousine Nerd Font Mono:size=16";
        include = pkgs.foot.src + "/themes/nord";
      };
      mouse.hide-when-typing = "yes";
      scrollback.indicator-position = "none";
      key-bindings = {
        scrollback-up-line = "Control+k";
        scrollback-down-line = "Control+j";
      };
    };
  };
}
