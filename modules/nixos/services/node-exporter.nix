{ config, lib, ... }:
{
  options.host.services.node-exporter.enable = lib.mkEnableOption "the Prometheus node exporter";

  config = lib.mkIf config.host.services.node-exporter.enable {
    services.prometheus.exporters.node = {
      enable = true;
      # calcifer's firewall and VictoriaMetrics' scrape config use this port
      port = 9100;
      enabledCollectors = [ "systemd" ];
    };
  };
}
