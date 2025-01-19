{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.services.gaming;
in
with lib;
{
  options = {
    host.services.gaming = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables gaming packages";
      };
    };
  };

  config = mkIf cfg.enable {
    # Enable steam
    programs.steam.enable = true;

    environment.systemPackages = with pkgs; [
      lutris
      protonup-qt
    ];
  };
}
