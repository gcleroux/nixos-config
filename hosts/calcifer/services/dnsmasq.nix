{
  inputs,
  config,
  lib,
  pkgs,
  hostname,
  outputs,
  ...
}:
{
  services = {
    prometheus.exporters.dnsmasq = {
      enable = true;
      extraFlags = [ "--expose_leases true" ];
      port = 9103;
      dnsmasqListenAddress = "localhost:1053";

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

        dhcp-range = [ "br-lan,192.168.0.100,192.168.0.250,12h" ];
        dhcp-lease-max = 150;
        interface = "br-lan";
        port = 1053;

        local = "/internal/";
        domain = "internal";
        expand-hosts = true;

        # Set static IP in DHCP
        no-hosts = true;
        address = [
          "/${hostname}.internal/192.168.0.10" # Static IP for router
          "/home-server/10.0.0.3" # Proxmox node
        ];
        dhcp-host = [
          "192.168.0.10" # Static IP for router
          "1c:2a:a3:24:04:ac,10.0.0.10,switch" # Smart switch
          "4c:ea:41:67:19:c8,10.0.0.20,nixos-worker-01" # K8s worker node
          "b8:2d:28:db:c6:cd,supernote"
        ];
        dhcp-option = "option:dns-server,192.168.0.10";
      };
    };
  };
}
