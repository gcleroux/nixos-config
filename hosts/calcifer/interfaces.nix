{
  config,
  lib,
  hostname,
  inventory,
  ...
}:
let
  addr = inventory.hosts.${hostname};

  wgSecret = sopsFile: {
    inherit sopsFile;
    format = "binary";
    owner = "systemd-network";
  };

  # VLANs on the LAN ports, and on br-lan's own port for the guest and cluster netdevs
  trunk = [
    {
      PVID = 1;
      EgressUntagged = 1;
    } # LAN, untagged
    { VLAN = 20; } # Guest, tagged
    { VLAN = 30; } # Cluster nodes, tagged
  ];
in
{
  networking = {
    useNetworkd = true;
    useDHCP = false;
  };
  # blocky answers DNS on port 53; networkd would otherwise turn resolved on
  services.resolved.enable = false;

  systemd.network = {
    wait-online.anyInterface = true;

    config.networkConfig = {
      IPv4Forwarding = true;
      IPv6Forwarding = true;
      ManageForeignRoutes = false;
    };

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
      "20-cluster" = {
        netdevConfig = {
          Description = "Cluster VLAN 30";
          Kind = "vlan";
          Name = "cluster";
        };
        vlanConfig.Id = 30;
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
        wireguardPeers = lib.mapAttrsToList (name: peer: {
          PublicKey = lib.fileContents ./wireguard/${name}/public.key;
          PresharedKeyFile = config.sops.secrets."wireguard/${name}/psk.key".path;
          AllowedIPs = [
            "${peer.ipv4}/32"
            "${peer.ipv6}/128"
          ];
        }) inventory.vpnPeers;
      };
    };

    networks = {
      "10-wan0" = {
        matchConfig.Name = "wan0";

        # Attach VLAN 40 to this physical interface.
        vlan = [ "ebox-wan" ];

        networkConfig = {
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
          LinkLocalAddressing = "no";
          IPv6AcceptRA = false;
        };

        linkConfig.RequiredForOnline = false;
      };

      "12-ebox0" = {
        matchConfig.Name = "ebox0";

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

      "30-lan" = {
        matchConfig.Name = "lan0 lan1 lan2";
        networkConfig = {
          Bridge = "br-lan";
          ConfigureWithoutCarrier = true;
        };
        bridgeVLANs = trunk;
        linkConfig.RequiredForOnline = false;
      };
      "40-br-lan" = {
        matchConfig.Name = "br-lan";
        bridgeVLANs = trunk;
        vlan = [
          "guest"
          "cluster"
        ];
        address = [
          "${addr.lan4}/24"
        ];
        networkConfig = {
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
        address = [ "${addr.guest4}/24" ];
        networkConfig = {
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
      "46-cluster" = {
        matchConfig.Name = "cluster";
        address = [ "${addr.cluster4}/24" ];
        networkConfig = {
          ConfigureWithoutCarrier = true;
          DHCPPrefixDelegation = true;
          IPv6SendRA = true;
        };
        # <prefix>:30::/64, subnet ID matches the VLAN ID
        dhcpPrefixDelegationConfig = {
          UplinkInterface = "ebox0";
          SubnetId = "0x30";
          Token = "::1";
        };
        ipv6SendRAConfig.EmitDNS = false;
        linkConfig.RequiredForOnline = false;
      };
      "50-wg0" = {
        matchConfig.Name = "wg0";
        address = [
          "${addr.vpn4}/24"
          "${addr.vpn6}/64"
        ];
      };
    };
  };

  sops.secrets = {
    "wireguard/calcifer/private.key" = wgSecret ./wireguard/calcifer/private.key;
  }
  // lib.mapAttrs' (
    name: _: lib.nameValuePair "wireguard/${name}/psk.key" (wgSecret ./wireguard/${name}/psk.key)
  ) inventory.vpnPeers;
}
