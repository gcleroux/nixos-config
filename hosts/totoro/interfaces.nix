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
  networking = {
    hostName = hostname;
    useNetworkd = true;
    useDHCP = false;

    nat.enable = false;
    firewall.enable = false;
  };

  systemd.network = {
    wait-online.anyInterface = true;

    # Rename links to match device's labels
    links = {
      "10-lan0" = {
        matchConfig.Path = "pci-0000:28:00.0";
        linkConfig = {
          Description = "Realtek 2.5 GbE";
          Name = "lan0";
        };
      };
      "10-lan1" = {
        matchConfig.Path = "pci-0000:2a:00.0";
        linkConfig = {
          Description = "Intel on-board I211";
          Name = "lan1";
        };
      };
    };

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
      "30-lan0" = {
        matchConfig.Name = "lan0";
        networkConfig = {
          Bridge = "br-lan";
          ConfigureWithoutCarrier = true;
        };
        linkConfig.RequiredForOnline = false;
      };
      "30-lan1" = {
        matchConfig.Name = "lan1";
        networkConfig = {
          Bridge = "br-lan";
          ConfigureWithoutCarrier = true;
        };
        linkConfig.RequiredForOnline = false;
      };

      "40-br-lan" = {
        matchConfig.Name = "br-lan";
        bridgeConfig = { };
        networkConfig = {
          DHCP = "ipv4";
          IPv4ReversePathFilter = "no";
          ConfigureWithoutCarrier = true;
        };
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
}
