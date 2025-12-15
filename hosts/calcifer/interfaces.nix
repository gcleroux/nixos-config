{
  systemd.network = {
    wait-online.anyInterface = true;

    # Rename links to match device's labels
    links = {
      "10-eth0" = {
        matchConfig.Path = "pci-0000:01:00.0";
        linkConfig = {
          Description = "eth0";
          Name = "lan0";
        };
      };
      "10-eth1" = {
        matchConfig.Path = "pci-0000:02:00.0";
        linkConfig = {
          Description = "eth1";
          Name = "lan1";
        };
      };
      "10-eth2" = {
        matchConfig.Path = "pci-0000:03:00.0";
        linkConfig = {
          Description = "eth2";
          Name = "lan2";
        };
      };
      "10-eth3" = {
        matchConfig.Path = "pci-0000:04:00.0";
        linkConfig = {
          Description = "eth3";
          Name = "wan0";
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

      # VLANs
      "20-vlan30" = {
        netdevConfig = {
          Description = "Guest VLAN";
          Kind = "vlan";
          Name = "vlan30";
        };
        vlanConfig.Id = 30;
      };
      "20-vlan99" = {
        netdevConfig = {
          Description = "Management VLAN";
          Kind = "vlan";
          Name = "vlan99";
        };
        vlanConfig.Id = 99;
      };
    };

    networks = {
      "10-wan0" = {
        matchConfig.Name = "wan0";
        networkConfig = {
          DHCP = "ipv4";
          DNS = "127.0.0.1";
          DNSOverTLS = false;
          DNSSEC = false;
          IPv4Forwarding = true;
          IPv6Forwarding = false;
          IPv6PrivacyExtensions = false;
        };
        # Don't use upstream's DNS server
        dhcpV4Config.UseDNS = false;
        dhcpV6Config.UseDNS = false;
        # make routing on this interface a dependency for network-online.target
        linkConfig.RequiredForOnline = "routable";
      };

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
      "30-lan2" = {
        # VLAN trunk
        matchConfig.Name = "lan2";
        networkConfig = {
          Bridge = "br-lan";
          ConfigureWithoutCarrier = true;
        };
        vlan = [
          "vlan30"
          "vlan99"
        ];
        linkConfig.RequiredForOnline = false;
      };
      "40-br-lan" = {
        matchConfig.Name = "br-lan";
        bridgeConfig = { };
        address = [
          "10.0.0.1/24"
        ];
        networkConfig = {
          IPv4ReversePathFilter = "no";
          ConfigureWithoutCarrier = true;
        };
      };
      "40-vlan30" = {
        matchConfig.Name = "vlan30";
        address = [
          "10.0.1.1/24"
        ];
        networkConfig.ConfigureWithoutCarrier = true;
      };
      "40-vlan99" = {
        matchConfig.Name = "vlan99";
        address = [
          "10.0.255.1/24"
        ];
        networkConfig.ConfigureWithoutCarrier = true;
      };
    };
  };
}
