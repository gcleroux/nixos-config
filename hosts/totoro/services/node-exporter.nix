{
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    enabledCollectors = [ "systemd" ];
    extraFlags = [ "--collector.textfile.directory=/var/lib/node-exporter-textfile" ];
  };

  systemd.tmpfiles.rules = [ "d /var/lib/node-exporter-textfile 0755 root root -" ];
}
