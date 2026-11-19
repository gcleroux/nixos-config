{
  config,
  lib,
  pkgs,
  inventory,
  ...
}:
let
  # Hosts pulled nightly, with the snapshot names of the subvolumes they snapshot hourly
  # (host.services.btrbk-source on each)
  sources = {
    calcifer = {
      address = inventory.hosts.calcifer.lan4;
      onCalendar = "*-*-* 03:30:00";
      subvolumes."@" = "root";
    };
    nixos-worker-01 = {
      address = inventory.hosts.nixos-worker-01.cluster4;
      onCalendar = "*-*-* 04:00:00";
      subvolumes = {
        "@appdata" = "appdata";
        "@k3s-server" = "k3s-server";
      };
    };
  };

  # Publishes when the newest copy of each subvolume was taken, for alerts
  backupAgeMetric =
    host: source:
    pkgs.writeShellScript "btrbk-${host}-metric" ''
      set -euo pipefail
      out=/var/lib/node-exporter-textfile/btrbk-${host}.prom
      for name in ${lib.escapeShellArgs (lib.attrValues source.subvolumes)}; do
        backups=(/srv/Backups/${host}/"$name".*[+-][0-9][0-9][0-9][0-9])
        ts=''${backups[-1]##*/"$name".}
        seconds=$(date -d "''${ts:0:8} ''${ts:9:2}:''${ts:11:2}:''${ts:13:2} ''${ts:15:5}" +%s)
        echo "btrbk_newest_backup_timestamp_seconds{backup=\"${host}\",snapshot=\"$name\"} $seconds"
      done > "$out.tmp"
      mv "$out.tmp" "$out"
    '';
in
{
  # Backups pulled from the other machines, not exported over NFS.
  # btrbk logs in with the sops key btrbk/ssh_key; the sources trust ssh_key.pub.
  fileSystems."/srv/Backups" = {
    device = "/dev/disk/by-uuid/c711808d-120c-4c5b-9cf1-07794b061681";
    fsType = "btrfs";
    options = [
      "nofail"
      "noatime"
      "nosuid"
      "nodev"
      "noexec"
      "compress=zstd"
      "subvol=@backups"
    ];
  };

  services.btrbk.instances = lib.mapAttrs (host: source: {
    inherit (source) onCalendar;
    settings = {
      ssh_identity = config.sops.secrets."btrbk/ssh_key".path;
      ssh_user = "btrbk";
      target_preserve_min = "latest";
      target_preserve = "14d 8w 12m";
      incremental_clones = "no";
      volume."ssh://${source.address}/mnt/btr_pool" = {
        target = "/srv/Backups/${host}";
        subvolume = lib.mapAttrs (_: name: {
          snapshot_dir = "@snapshots";
          snapshot_name = name;
          snapshot_create = "no";
          snapshot_preserve_min = "all";
        }) source.subvolumes;
      };
    };
  }) sources;

  systemd.services = lib.mapAttrs' (
    host: source:
    lib.nameValuePair "btrbk-${host}" {
      # Fail rather than write to the root disk if the backup disk isn't mounted
      unitConfig.RequiresMountsFor = [ "/srv/Backups" ];
      # runs as root, since only root can list /srv/Backups
      serviceConfig.ExecStartPost = "+${backupAgeMetric host source}";
    }
  ) sources;

  services.prometheus.exporters.node.extraFlags = [
    "--collector.textfile.directory=/var/lib/node-exporter-textfile"
  ];
  systemd.tmpfiles.rules = [
    "d /var/lib/node-exporter-textfile 0755 root root -"
  ]
  # btrbk receives into existing directories only
  ++ map (host: "d /srv/Backups/${host} 0755 root root -") (lib.attrNames sources);

  sops.secrets."btrbk/ssh_key" = {
    sopsFile = ./secrets.yaml;
    owner = "btrbk";
  };
}
