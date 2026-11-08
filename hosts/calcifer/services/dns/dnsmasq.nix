{
  inputs,
  config,
  lib,
  pkgs,
  hostname,
  outputs,
  ...
}:
let
  inherit (import ../../subnets.nix) lan4 lan6 guest4;
  gatewayIP = builtins.elemAt (lib.strings.splitString "/" (
    builtins.elemAt config.systemd.network.networks."40-br-lan".address 0
  )) 0;
  guestGatewayIP = builtins.elemAt (lib.strings.splitString "/" (
    builtins.elemAt config.systemd.network.networks."45-guest".address 0
  )) 0;
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
          "/${hostname}.lan/${gatewayIP}" # Static IP for router
        ];
        dhcp-host = [
          gatewayIP # Static IP for router
          "4c:ea:41:67:19:c8,${lan4}.20,nixos-worker-01" # K8s worker node
          "b8:2d:28:db:c6:cd,supernote"
        ];
        dhcp-option = [
          "tag:br-lan,option:dns-server,${gatewayIP}"
          "tag:guest,option:dns-server,${guestGatewayIP}"
        ];
        host-record = [
          "totoro.lan,${lan4}.2,${lan6}::2" # NAS, static on the host
          "lldap.lan,${gatewayIP}"
          "switch.lan,${lan4}.10"
          "u6-plus.lan,${lan4}.11"
        ];
      };
    };
  };
}
