{
  services.mako = {
    enable = true;
    extraConfig = ''
      [category=overlay]
      font=monospace 16
      text-alignment=center
      layer=overlay
      default-timeout=1000

      [app-name=spotify_player]
      default-timeout=2000

      [app-name=blueman]
      default-timeout=5000
    '';
    settings = {
      anchor = "top-right";
      max-visible = 5;
      font = "monospace 12";
      background-color = "#2e3440";
      border-color = "#81a1c1";
      border-radius = 8;
      border-size = 3;
      text-color = "#e5e9f0";
      progress-color = "#88c0d0";
      width = 300;
      height = 200;
    };
  };
}
