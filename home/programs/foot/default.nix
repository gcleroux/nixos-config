{ pkgs, ... }: {
  programs.foot = {
    enable = true;
    settings = {
      main = {
        term = "xterm-256color";
        font = "Cousine Nerd Font Mono:size=16";
        include = pkgs.foot.src + "/themes/nord";
      };
      mouse = { hide-when-typing = "yes"; };
    };
  };
}
