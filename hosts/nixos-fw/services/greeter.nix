{ config, pkgs, ... }:
let
  # Only the display manager's entries: uwsm also links them into /run/current-system/sw/share,
  # which tuigreet would list a second time
  sessions = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
in
{
  services.greetd = {
    enable = true;
    restart = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet -d --time --remember --remember-session --sessions ${sessions} --session-wrapper '>/tmp/tuigreet-session.log 2>&1'";
        user = "greeter";
      };
    };
  };
}
