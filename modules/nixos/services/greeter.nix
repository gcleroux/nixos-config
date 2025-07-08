{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.services.greeter;
in
with lib;
{
  options = {
    host.services.greeter = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Install greeter";
      };
    };
  };

  config = mkIf cfg.enable {

    services.greetd = {
      enable = true;
      restart = true;
      vt = 1;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet -d --time --remember --remember-session --session-wrapper '>/tmp/tuigreet-session.log 2>&1'";
          user = "greeter";
        };
      };
    };
    # Unlock gnome-keyring on login
    security.pam.services = lib.optionals config.host.services.keyring.enable {
      greetd.enableGnomeKeyring = true;
      greetd-password.enableGnomeKeyring = true;
      login.enableGnomeKeyring = true;
    };
  };
}
