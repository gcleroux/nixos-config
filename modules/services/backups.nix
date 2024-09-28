{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.services.backups;
in
with lib;
{
  options = {
    host.services.backups = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables btrfs backups";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ btrbk ];

    # Backup tool setup for the /home directory
    #TODO: Exclude ~/Downloads from backup
    services.btrbk = {
      instances = {
        daily = {
          onCalendar = "daily";
          settings = {
            snapshot_preserve = "14d";
            snapshot_preserve_min = "7d";
            volume = {
              "/" = {
                subvolume = {
                  "home" = {
                    snapshot_create = "always";
                  };
                };
                snapshot_dir = "/.snapshots/daily";
              };
            };
          };
        };
        weekly = {
          onCalendar = "weekly";
          settings = {
            snapshot_preserve = "5w";
            snapshot_preserve_min = "3w";
            volume = {
              "/" = {
                subvolume = {
                  "home" = {
                    snapshot_create = "always";
                  };
                };
                snapshot_dir = "/.snapshots/weekly";
              };
            };
          };
        };
        monthly = {
          onCalendar = "monthly";
          settings = {
            snapshot_preserve = "3m";
            snapshot_preserve_min = "2m";
            volume = {
              "/" = {
                subvolume = {
                  "home" = {
                    snapshot_create = "always";
                  };
                };
                snapshot_dir = "/.snapshots/monthly";
              };
            };
          };
        };
      };
    };
  };
}
