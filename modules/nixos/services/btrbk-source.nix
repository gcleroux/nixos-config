{ config, lib, ... }:
let
  cfg = config.host.services.btrbk-source;
  pool = "/mnt/btr_pool";
in
{
  options.host.services.btrbk-source = {
    enable = lib.mkEnableOption "hourly btrbk snapshots that totoro pulls over SSH";
    subvolumes = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      example = {
        "@" = "root";
      };
      description = "Subvolumes of the btrfs top level (mounted at ${pool}) to snapshot, and their snapshot names.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.btrbk = {
      instances.snapshots = {
        onCalendar = "hourly";
        settings = {
          timestamp_format = "long-iso";
          snapshot_preserve_min = "2d";
          snapshot_preserve = "14d 4w";
          volume.${pool} = {
            snapshot_dir = "@snapshots";
            subvolume = lib.mapAttrs (_: name: { snapshot_name = name; }) cfg.subvolumes;
          };
        };
      };

      # totoro's btrbk SSH key, can only read the snapshots
      sshAccess = [
        {
          key = builtins.readFile ../../../hosts/totoro/services/backups/ssh_key.pub;
          roles = [ "send" ];
          extraArgs = lib.concatMap (subvol: [
            "--restrict-path"
            "${pool}/${subvol}"
          ]) (lib.attrNames cfg.subvolumes ++ [ "@snapshots" ]);
        }
      ];
    };
    services.openssh.extraConfig = ''
      Match User btrbk
        DisableForwarding yes
        PermitTTY no
    '';
  };
}
