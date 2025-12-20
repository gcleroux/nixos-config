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
      "50-wg0" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
        };
        wireguardConfig = {
          PrivateKeyFile = config.sops.secrets."wireguard/calcifer/private.key".path;
          ListenPort = 51820;
        };
        wireguardPeers = [
          {
            PublicKey = builtins.readFile ./wireguard/s24-ultra/public.key;
            PresharedKeyFile = config.sops.secrets."wireguard/s24-ultra/psk.key".path;
            AllowedIPs = [ "10.0.9.100/32" ];
          }
          {
            PublicKey = builtins.readFile ./wireguard/nixos-fw/public.key;
            PresharedKeyFile = config.sops.secrets."wireguard/nixos-fw/psk.key".path;
            AllowedIPs = [ "10.0.9.101/32" ];
          }
          {
            PublicKey = builtins.readFile ./wireguard/iphone-lapin/public.key;
            PresharedKeyFile = config.sops.secrets."wireguard/iphone-lapin/psk.key".path;
            AllowedIPs = [ "10.0.9.102/32" ];
          }
          {
            PublicKey = builtins.readFile ./wireguard/mac-lapin/public.key;
            PresharedKeyFile = config.sops.secrets."wireguard/mac-lapin/psk.key".path;
            AllowedIPs = [ "10.0.9.103/32" ];
          }
        ];
      };
    };

    networks = {
      "10-wan0" = {
        matchConfig.Name = "wan0";
        networkConfig = {
          DHCP = "ipv4";
          DNS = "127.0.0.1";
          DNSOverTLS = false;
          DNSSEC = true;
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
        linkConfig.RequiredForOnline = false;
      };
      "40-vlan99" = {
        matchConfig.Name = "vlan99";
        address = [
          "10.0.255.1/24"
        ];
        networkConfig.ConfigureWithoutCarrier = true;
        linkConfig.RequiredForOnline = false;
      };
      "50-wg0" = {
        matchConfig.Name = "wg0";
        address = [ "10.0.9.1/24" ];
        networkConfig = {
          IPv4Forwarding = true;
          DNS = "127.0.0.1";
        };
      };
    };
  };

  sops.secrets = {
    "wireguard/calcifer/private.key" = {
      sopsFile = ./wireguard/calcifer/private.key;
      key = "data";
      mode = "0640";
      owner = "systemd-network";
      group = "systemd-network";
    };
    "wireguard/s24-ultra/psk.key" = {
      sopsFile = ./wireguard/s24-ultra/psk.key;
      key = "data";
      mode = "0640";
      owner = "systemd-network";
      group = "systemd-network";
    };
    "wireguard/nixos-fw/psk.key" = {
      sopsFile = ./wireguard/nixos-fw/psk.key;
      key = "data";
      mode = "0640";
      owner = "systemd-network";
      group = "systemd-network";
    };
    "wireguard/iphone-lapin/psk.key" = {
      sopsFile = ./wireguard/iphone-lapin/psk.key;
      key = "data";
      mode = "0640";
      owner = "systemd-network";
      group = "systemd-network";
    };
    "wireguard/mac-lapin/psk.key" = {
      sopsFile = ./wireguard/mac-lapin/psk.key;
      key = "data";
      mode = "0640";
      owner = "systemd-network";
      group = "systemd-network";
    };
  };
}
