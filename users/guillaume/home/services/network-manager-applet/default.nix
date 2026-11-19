{ config, ... }:
{
  services.network-manager-applet.enable = true;

  # The service only runs nm-applet; this also puts nm-connection-editor on PATH
  home.packages = [ config.services.network-manager-applet.package ];

  # uwsm runs XDG autostart entries: hide the package's own so only the service starts nm-applet
  xdg.configFile."autostart/nm-applet.desktop".text = ''
    [Desktop Entry]
    Hidden=true
  '';
}
