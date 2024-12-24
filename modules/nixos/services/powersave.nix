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
    services.auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };
    };

  };
}
