{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.services.keyring;
in
with lib;
{
  options = {
    host.services.keyring = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Install keyring";
      };
    };
  };

  config = mkIf cfg.enable {
    services.gnome.gnome-keyring.enable = true;
    programs.seahorse.enable = true;
  };
}
