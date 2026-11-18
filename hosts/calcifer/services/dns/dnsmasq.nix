{
  inputs,
  config,
  lib,
  pkgs,
  hostname,
  outputs,
  inventory,
  ...
}:
let
  inherit (inventory.subnets) lan4 guest4;
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
        domain-needed = true;
        localise-queries = true;
        stop-dns-rebind = true;
        dhcp-authoritative = true;
        cache-size = 1000;
        no-resolv = true;

        # The leading word is a dnsmasq *tag* (set:<tag>), not an interface binding;
        # dnsmasq picks the range matching the subnet of the receiving interface.
        dhcp-range = [
          "br-lan,${lan4}.100,${lan4}.250,12h"
          "set:guest,${guest4}.100,${guest4}.250,4h"
        ];
        dhcp-lease-max = 300; # Global across all ranges
        interface = [
          "br-lan"
          "guest"
        ];
        # Don't let guest devices register names in the .lan zone
        dhcp-ignore-names = "tag:guest";
        port = 1053;

        local = "/lan/";
        domain = "lan";
        expand-hosts = true;

        # Set static IP in DHCP
        no-hosts = true;
        address = [
          "/${hostname}.lan/${addr.lan4}" # Static IP for router
        ];
        dhcp-host = [
          addr.lan4 # Static IP for router
          "b8:2d:28:db:c6:cd,supernote"
        ];
        dhcp-option = [
          "tag:br-lan,option:dns-server,${addr.lan4}"
          "tag:guest,option:dns-server,${addr.guest4}"
        ];
        host-record = [
          "totoro.lan,${totoro.lan4},${totoro.lan6}" # NAS, static on the host
          "nixos-worker-01.lan,${nixos-worker-01.cluster4},${nixos-worker-01.cluster6}" # K8s node, static on VLAN 30
          "lldap.lan,${addr.lan4}"
          "switch.lan,${lan4}.10"
          "u6-plus.lan,${lan4}.11"
        ];
      };
    };
  };
}
