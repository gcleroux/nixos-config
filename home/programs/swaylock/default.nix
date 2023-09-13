{
  xdg.configFile = { "swaylock/swaylock.png".source = ./swaylock.png; };

  programs.swaylock = {
    enable = true;
    settings = {
      daemonize = true;
      ignore-empty-password = true;
      indicator-caps-lock = true;
      image = "$HOME/.config/swaylock/swaylock.png";
      scaling = "fill";
      font = "Cousine Nerd Font Mono";
      font-size = "20";
      indicator-radius = "115";
      line-color = "#3b4252";
      text-color = "#d8dee9";
      inside-color = "#2e344098";
      inside-ver-color = "#5e81ac";
      line-ver-color = "#5e81ac";
      ring-ver-color = "#5e81ac98";
      ring-color = "#4c566a";
      key-hl-color = "#5e81ac";
      separator-color = "#4c566a";
      layout-text-color = "#eceff4";
      line-wrong-color = "#d08770";
    };

  };
}
