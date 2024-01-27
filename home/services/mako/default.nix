{
  services.mako = {
    enable = true;
    anchor = "top-right";
    maxVisible = 5;
    font = "Cousine Nerd Font Mono 12";
    backgroundColor = "#2e3440";
    borderColor = "#81a1c1";
    borderRadius = 8;
    borderSize = 3;
    textColor = "#e5e9f0";
    progressColor = "#88c0d0";
    extraConfig = ''
      [category=overlay]
      font=Cousine Nerd Font Mono 16
      width=280
      text-alignment=center
      layer=overlay
      anchor=center
      default-timeout=1000

      [app-name=spotify_player]
      default-timeout=2000
    '';

  };
}
