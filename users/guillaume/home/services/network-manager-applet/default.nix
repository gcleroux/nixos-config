{ config, ... }:
{
  services.network-manager-applet.enable = true;

  # The service only runs nm-applet; this also puts nm-connection-editor on PATH
  home.packages = [ config.services.network-manager-applet.package ];
}
