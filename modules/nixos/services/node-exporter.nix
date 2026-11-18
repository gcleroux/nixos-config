{
  config,
  lib,
  ...
}:
let
  cfg = config.host.services.node-exporter;
in
with lib;
{
  options = {
    host.services.node-exporter = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables the Prometheus node exporter";
      };
    };
  };

  config = mkIf cfg.enable {
    services.prometheus.exporters.node = {
      enable = true;
      port = 9100;
      enabledCollectors = [ "systemd" ];
    };
  };
}
