{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.services.polkit;
in
with lib;
{
  options = {
    host.services.polkit = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables polkit";
      };
    };
  };

  config = mkIf cfg.enable {
    security.polkit.enable = true;

    systemd = {
      user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };
  };
}
