{
  services.blueman-applet.enable = true;

  # uwsm runs XDG autostart entries: hide blueman's own so only the service starts the applet
  xdg.configFile."autostart/blueman.desktop".text = ''
    [Desktop Entry]
    Hidden=true
  '';
}
