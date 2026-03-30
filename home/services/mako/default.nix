{
  services.mako = {
    enable = true;
    # extraConfig = ''
    #   [category=overlay]
    #   font=monospace 14
    #   text-alignment=center
    #   layer=overlay
    #   default-timeout=1000
    #
    #   [app-name=spotify_player]
    #   default-timeout=2000
    #
    #   [app-name=blueman]
    #   default-timeout=5000
    # '';
    settings = {
      actions = true;
      anchor = "top-right";
      layer = "top";
      icons = true;
      default-timeout = 0;
      ignore-timeout = false;
      markup = true;
      max-visible = 5;

      font = "monospace 12";
      background-color = "#2e3440";
      border-color = "#81a1c1";
      border-radius = 8;
      border-size = 3;
      text-color = "#e5e9f0";
      progress-color = "#88c0d0";

      margin = 10;
      width = 300;
      height = 200;
    };
  };
}
