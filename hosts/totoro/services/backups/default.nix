{
  config,
  pkgs,
  inventory,
  ...
}:
let
  # Publishes when the newest copy of calcifer was taken, for alerts
  backupAgeMetric = pkgs.writeShellScript "btrbk-calcifer-metric" ''
    set -euo pipefail
    backups=(/srv/Backups/calcifer/root.*[+-][0-9][0-9][0-9][0-9])
    ts=''${backups[-1]##*/root.}
    seconds=$(date -d "''${ts:0:8} ''${ts:9:2}:''${ts:11:2}:''${ts:13:2} ''${ts:15:5}" +%s)
    out=/var/lib/node-exporter-textfile/btrbk-calcifer.prom
    echo "btrbk_newest_backup_timestamp_seconds{backup=\"calcifer\"} $seconds" > "$out.tmp"
    mv "$out.tmp" "$out"
  '';
in
{
  # Backups pulled from the other machines, not exported over NFS.
  # btrbk logs in with the sops key btrbk/ssh_key; calcifer trusts ssh_key.pub.
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

  services.btrbk.instances.calcifer = {
    onCalendar = "*-*-* 03:30:00"; # Every day at 3:30am
    settings = {
      ssh_identity = config.sops.secrets."btrbk/ssh_key".path;
      ssh_user = "btrbk";
      target_preserve_min = "latest";
      target_preserve = "14d 8w 12m";
      incremental_clones = "no";
      volume."ssh://${inventory.hosts.calcifer.lan4}/mnt/btr_pool" = {
        target = "/srv/Backups/calcifer";
        subvolume."@" = {
          snapshot_dir = "@snapshots";
          snapshot_name = "root";
          snapshot_create = "no";
          snapshot_preserve_min = "all";
        };
      };
    };
  };

  # Fail rather than write to the root disk if the backup disk isn't mounted
  systemd.services.btrbk-calcifer.unitConfig.RequiresMountsFor = [ "/srv/Backups" ];
  # runs as root, since only root can list /srv/Backups
  systemd.services.btrbk-calcifer.serviceConfig.ExecStartPost = "+${backupAgeMetric}";

  services.prometheus.exporters.node.extraFlags = [
    "--collector.textfile.directory=/var/lib/node-exporter-textfile"
  ];
  systemd.tmpfiles.rules = [ "d /var/lib/node-exporter-textfile 0755 root root -" ];

  sops.secrets."btrbk/ssh_key" = {
    sopsFile = ./secrets.yaml;
    owner = "btrbk";
  };
}
