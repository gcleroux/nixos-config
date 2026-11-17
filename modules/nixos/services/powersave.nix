{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.services.powersave;
in
with lib;
{
  options = {
    host.services.powersave = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables powersave options";
      };
    };
  };

  config = mkIf cfg.enable {
    services = {
      thermald.enable = true;
      tlp = {
        enable = true;
        settings = {
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

          START_CHARGE_THRESH_BAT0 = 75;
          STOP_CHARGE_THRESH_BAT0 = 80;
        };
      };
    };
  };
}
