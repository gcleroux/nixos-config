{
  config,
  hostname,
  inventory,
  ...
}:
let
  inherit (inventory) ip;
  inherit (inventory.cidrs) lan4 guest4;
  inherit (inventory.hosts) totoro nixos-worker-01;
  addr = inventory.hosts.${hostname};
in
{
  services = {
    prometheus.exporters.dnsmasq = {
      enable = true;
      extraFlags = [ "--expose_leases true" ];
      port = 9103;
      dnsmasqListenAddress = "localhost:${toString config.services.dnsmasq.settings.port}";

    };
    dnsmasq = {
      enable = true;
      settings = {
        dhcp-authoritative = true;
        cache-size = 1000;
        no-resolv = true;

        dhcp-range = [
          "${ip lan4 100},${ip lan4 250},12h"
          "${ip guest4 100},${ip guest4 250},4h"
        ];
        dhcp-lease-max = 300; # Global across all ranges
        interface = [
          "br-lan"
          "guest"
        ];
        # Don't let guest devices register names in the .lan zone. Each request is tagged
        # with the interface it arrived on.
        dhcp-ignore-names = "tag:guest";
        port = 1053;

        local = "/lan/";
        domain = "lan";
        no-hosts = true;
        dhcp-host = [ "b8:2d:28:db:c6:cd,supernote" ];
        # The router's own address on each subnet
        dhcp-option = [ "option:dns-server,0.0.0.0" ];
        host-record = [
          "${hostname}.lan,${addr.lan4}" # First, so it owns 10.0.0.1's PTR
          "totoro.lan,${totoro.lan4},${totoro.lan6}" # NAS, static on the host
          "nixos-worker-01.lan,${nixos-worker-01.cluster4},${nixos-worker-01.cluster6}" # K8s node, static on VLAN 30
          "switch.lan,${ip lan4 10}"
          "u6-plus.lan,${ip lan4 11}"
        ];
      };
    };
  };
}
