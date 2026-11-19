{ pkgs, ... }:
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        shell = "${pkgs.fish}/bin/fish";
        font = "Cousine Nerd Font Mono:size=16";
        include = "${pkgs.foot.themes}/share/foot/themes/nord";
      };
      scrollback.indicator-position = "none";
      key-bindings = {
        scrollback-up-line = "Control+Shift+k";
        scrollback-down-line = "Control+Shift+j";
      };
    };
  };
}
