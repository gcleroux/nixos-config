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
  gatewayIP = "192.168.0.10";

  bytes = lib.splitString "." gatewayIP;
  netPrefix = lib.concatStringsSep "." (lib.take 3 bytes);
in
{
  ### Interfaces
  systemd.network = {
    wait-online.anyInterface = true;
    netdevs = {
      # Create the bridge interface
      "20-br-lan" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br-lan";
        };
      };
    };

    networks = {
      "10-wan" = {
        matchConfig.Name = "enp1s0";
        networkConfig = {
          DHCP = "ipv4";
          DNSOverTLS = true;
          DNSSEC = true;
          IPv4Forwarding = true;
          IPv6Forwarding = false;
          IPv6PrivacyExtensions = false;
        };
        # make routing on this interface a dependency for network-online.target
        linkConfig.RequiredForOnline = "routable";
      };

      "30-lan0" = {
        matchConfig.Name = "enp4s0";
        networkConfig = {
          Bridge = "br-lan";
          ConfigureWithoutCarrier = true;
        };
        linkConfig.RequiredForOnline = "enslaved";
      };
      "30-lan1" = {
        matchConfig.Name = "enp3s0";
        networkConfig = {
          Bridge = "br-lan";
          ConfigureWithoutCarrier = true;
        };
        linkConfig.RequiredForOnline = "enslaved";
      };
      "30-lan2" = {
        matchConfig.Name = "enp2s0";
        networkConfig = {
          Bridge = "br-lan";
          ConfigureWithoutCarrier = true;
        };
        linkConfig.RequiredForOnline = "enslaved";
      };
      "40-br-lan" = {
        matchConfig.Name = "br-lan";
        bridgeConfig = { };
        address = [
          "${gatewayIP}/24"
        ];
        networkConfig = {
          ConfigureWithoutCarrier = true;
        };
      };
    };
  };

  ### Firewall
  networking = {
    hostName = hostname;
    useNetworkd = true;
    useDHCP = false;

    nat.enable = false;
    firewall.enable = false;
  };

  ### DHCP
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

        dhcp-range = [ "br-lan,${netPrefix}.100,${netPrefix}.250,12h" ];
        dhcp-lease-max = 150;
        interface = "br-lan";
        dhcp-host = gatewayIP;

        local = "/lan/";
        domain = "lan";
        expand-hosts = true;

        # Set static IP in DHCP
        no-hosts = true;
        address = "/${hostname}.lan/${gatewayIP}";
      };
    };
  };
}
