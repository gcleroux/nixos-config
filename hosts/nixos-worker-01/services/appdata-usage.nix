{ pkgs, ... }:
{
  # Disk usage of each app volume, for alerts. The kubelet only reports the whole filesystem for
  # local-path volumes. The k8s node-exporter reads the textfile through its /host/root mount.
  systemd.services.appdata-usage = {
    description = "Report the disk usage of each app volume";
    startAt = "*:0/15";
    path = [ pkgs.coreutils ];
    serviceConfig = {
      Type = "oneshot";
      StateDirectory = "node-exporter-textfile";
      Nice = 19;
      IOSchedulingClass = "idle";
    };
    # local-path names volume directories <pv>_<namespace>_<pvc>. The labels avoid "namespace",
    # which the scrape sets to the exporter's own.
    script = ''
      shopt -s nullglob
      out=/var/lib/node-exporter-textfile/appdata.prom
      for dir in /var/lib/appdata/pvc-*_*_*; do
        IFS=_ read -r pv namespace pvc <<<"''${dir##*/}"
        bytes=$(du -sB1 "$dir" | cut -f1)
        echo "appdata_volume_used_bytes{persistentvolume=\"$pv\",claim_namespace=\"$namespace\",claim=\"$pvc\"} $bytes"
      done >"$out.tmp"
      mv "$out.tmp" "$out"
    '';
  };
}
