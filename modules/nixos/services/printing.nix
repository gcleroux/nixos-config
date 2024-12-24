{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.services.printing;
in
with lib;
{
  options = {
    host.services.printing = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables printing";
      };
    };
  };

  config = mkIf cfg.enable {
    # Enable printing
    services.printing.enable = true;

    # Enable autodiscovery of network printers
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
