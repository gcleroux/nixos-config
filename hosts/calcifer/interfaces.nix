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

    # Unlike IPv4Forwarding, the per-link IPv6Forwarding setting doesn't make
    # the kernel forward IPv6 between interfaces; only the global one does.
    config.networkConfig.IPv6Forwarding = true;

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
          Name = "wan1";
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
        # Make the bridge VLAN-aware: LAN stays untagged on PVID 1,
        # guest traffic arrives tagged with VLAN 20.
        bridgeConfig = {
          VLANFiltering = true;
          DefaultPVID = 1;
        };
      };

      # VLANs
      "20-ebox-wan" = {
        netdevConfig = {
          Description = "Ebox WAN VLAN 40";
          Kind = "vlan";
          Name = "ebox-wan";
        };
        vlanConfig.Id = 40;
      };
      "20-guest" = {
        netdevConfig = {
          Description = "Guest VLAN 20";
          Kind = "vlan";
          Name = "guest";
        };
        vlanConfig.Id = 20;
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
          {
            PublicKey = builtins.readFile ./wireguard/s23-julie/public.key;
            PresharedKeyFile = config.sops.secrets."wireguard/s23-julie/psk.key".path;
            AllowedIPs = [ "10.0.9.104/32" ];
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

      "10-wan1" = {
        matchConfig.Name = "wan1";

        # Attach VLAN 40 to this physical interface.
        vlan = [ "ebox-wan" ];

        networkConfig = {
          DHCP = "no";
          LinkLocalAddressing = "no";
          IPv6AcceptRA = false;
          ConfigureWithoutCarrier = true;
        };

        linkConfig.RequiredForOnline = false;
      };

      "11-ebox-wan" = {
        matchConfig.Name = "ebox-wan";

        # The VLAN itself has no IP configuration.
        # PPPoE creates the ebox0 interface and obtains the WAN IP.
        networkConfig = {
          DHCP = "no";
          LinkLocalAddressing = "no";
          IPv6AcceptRA = false;
        };

        linkConfig.RequiredForOnline = false;
      };

      "12-ebox0" = {
        matchConfig.Name = "ebox0";

        # pppd owns this link and its IPv4 address and routes, keep them.
        # networkd adds IPv6: a WAN address by SLAAC, the default route from
        # the RA, and the /56 by DHCPv6-PD, which br-lan and guest use.
        networkConfig = {
          DHCP = "ipv6";
          IPv6AcceptRA = true;
          KeepConfiguration = "static";
        };
        ipv6AcceptRAConfig.UseDNS = false;
        dhcpV6Config = {
          PrefixDelegationHint = "::/56";
          WithoutRA = "solicit";
          UseDNS = false;
        };

        linkConfig.RequiredForOnline = false;
      };

      "30-lan0" = {
        matchConfig.Name = "lan0";
        networkConfig = {
          Bridge = "br-lan";
          ConfigureWithoutCarrier = true;
        };
        bridgeVLANs = [
          {
            PVID = 1;
            EgressUntagged = 1;
          } # LAN, untagged
          { VLAN = 20; } # Guest, tagged
        ];
        linkConfig.RequiredForOnline = false;
      };
      "30-lan1" = {
        matchConfig.Name = "lan1";
        networkConfig = {
          Bridge = "br-lan";
          ConfigureWithoutCarrier = true;
        };
        bridgeVLANs = [
          {
            PVID = 1;
            EgressUntagged = 1;
          } # LAN, untagged
          { VLAN = 20; } # Guest, tagged
        ];
        linkConfig.RequiredForOnline = false;
      };
      "40-br-lan" = {
        matchConfig.Name = "br-lan";
        bridgeConfig = { };
        # Bridge "self" port: untagged LAN for 10.0.0.1, tagged VLAN 20 for the guest netdev
        bridgeVLANs = [
          {
            PVID = 1;
            EgressUntagged = 1;
          }
          { VLAN = 20; }
        ];
        vlan = [ "guest" ];
        address = [
          "10.0.0.1/24"
        ];
        networkConfig = {
          IPv4ReversePathFilter = "no";
          ConfigureWithoutCarrier = true;
          DHCPPrefixDelegation = true;
          IPv6SendRA = true;
        };
        # <prefix>:00::/64 from the EBOX /56, announced by RA (SLAAC)
        dhcpPrefixDelegationConfig = {
          UplinkInterface = "ebox0";
          SubnetId = "0x0";
          Token = "::1";
        };
        ipv6SendRAConfig.DNS = "_link_local"; # blocky
      };
      "45-guest" = {
        matchConfig.Name = "guest";
        address = [ "10.0.20.1/24" ];
        networkConfig = {
          IPv4Forwarding = true;
          ConfigureWithoutCarrier = true;
          DHCPPrefixDelegation = true;
          IPv6SendRA = true;
        };
        # <prefix>:20::/64, subnet ID matches the VLAN ID
        dhcpPrefixDelegationConfig = {
          UplinkInterface = "ebox0";
          SubnetId = "0x20";
          Token = "::1";
        };
        ipv6SendRAConfig.DNS = "_link_local"; # blocky
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
    "wireguard/s23-julie/psk.key" = {
      sopsFile = ./wireguard/s23-julie/psk.key;
      key = "data";
      mode = "0640";
      owner = "systemd-network";
      group = "systemd-network";
    };
  };
}
