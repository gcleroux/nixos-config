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
        dhcp-host = "192.168.0.10";
        port = 1053;

        local = "/internal/";
        domain = "internal";
        expand-hosts = true;

        # Set static IP in DHCP
        no-hosts = true;
        address = "/${hostname}.internal/192.168.0.10";
        dhcp-option = "option:dns-server,192.168.0.10";
      };
    };
  };
}
