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
      restart = false;
      vt = 1;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --asterisks --time --cmd 'river -log-level debug >/tmp/river.log 2>&1'";
          user = "greeter";
        };
      };
    };
  };
}
