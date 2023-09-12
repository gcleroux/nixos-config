{
  services.mako = {
    enable = true;
    defaultTimeout = 5000;
    anchor = "top-right";
    font = "Cousine Nerd Font Mono 16";
    extraConfig = ''
      [category=overlay]
      width=200
      text-alignment=center
      layer=overlay
      anchor=center
    '';
  };
}
