{
  hostname,
  inventory,
  ...
}:
let
  addr = inventory.hosts.${hostname};
  router = inventory.hosts.calcifer.lan4;
in
{
  networking = {
    useNetworkd = true;
    useDHCP = false;
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
        # Static, below calcifer's DHCP pool: the cluster's firewall rule for NFS
        # names this address. IPv6 still accepts calcifer's RA for its routes.
        address = [
          "${addr.lan4}/24"
          "${addr.lan6}/64"
        ];
        gateway = [ router ];
        dns = [ router ];
        domains = [ "lan" ];
        networkConfig = {
          IPv4ReversePathFilter = "no";
          ConfigureWithoutCarrier = true;
        };
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
}
