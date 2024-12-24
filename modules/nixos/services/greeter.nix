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
      settings = rec {
        initial_session = {
          command = ''
            ${lib.makeBinPath [ pkgs.greetd.tuigreet ]}/tuigreet --remember --asterisks --time \
              --cmd "${pkgs.river}/bin/river &> /dev/null"
          '';
          user = "guillaume";
        };
        default_session = initial_session;
      };
    };
  };
}
