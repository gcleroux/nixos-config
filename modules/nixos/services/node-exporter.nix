{ config, lib, ... }:
{
  options.host.services.node-exporter.enable = lib.mkEnableOption "the Prometheus node exporter";

  config = lib.mkIf config.host.services.node-exporter.enable {
    services.prometheus.exporters.node = {
      enable = true;
      port = 9100;
      enabledCollectors = [ "systemd" ];
    };
  };
}
