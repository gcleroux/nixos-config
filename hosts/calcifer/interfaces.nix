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
  inherit (import ./subnets.nix)
    lan4
    guest4
    vpn4
    vpn6
    cluster4
    ;
in
{
  systemd.network = {
    wait-online.anyInterface = true;

    config.networkConfig = {
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
        wireguardPeers = [
          {
            PublicKey = builtins.readFile ./wireguard/s24-ultra/public.key;
            PresharedKeyFile = config.sops.secrets."wireguard/s24-ultra/psk.key".path;
            AllowedIPs = [
              "${vpn4}.100/32"
              "${vpn6}::100/128"
            ];
          }
          {
            PublicKey = builtins.readFile ./wireguard/nixos-fw/public.key;
            PresharedKeyFile = config.sops.secrets."wireguard/nixos-fw/psk.key".path;
            AllowedIPs = [
              "${vpn4}.101/32"
              "${vpn6}::101/128"
            ];
          }
          {
            PublicKey = builtins.readFile ./wireguard/iphone-lapin/public.key;
            PresharedKeyFile = config.sops.secrets."wireguard/iphone-lapin/psk.key".path;
            AllowedIPs = [
              "${vpn4}.102/32"
              "${vpn6}::102/128"
            ];
          }
          {
            PublicKey = builtins.readFile ./wireguard/mac-lapin/public.key;
            PresharedKeyFile = config.sops.secrets."wireguard/mac-lapin/psk.key".path;
            AllowedIPs = [
              "${vpn4}.103/32"
              "${vpn6}::103/128"
            ];
          }
          {
            PublicKey = builtins.readFile ./wireguard/s23-julie/public.key;
            PresharedKeyFile = config.sops.secrets."wireguard/s23-julie/psk.key".path;
            AllowedIPs = [
              "${vpn4}.104/32"
              "${vpn6}::104/128"
            ];
          }
          {
            PublicKey = builtins.readFile ./wireguard/z-fold-8/public.key;
            PresharedKeyFile = config.sops.secrets."wireguard/z-fold-8/psk.key".path;
            AllowedIPs = [
              "${vpn4}.105/32"
              "${vpn6}::105/128"
            ];
          }
        ];
      };
    };

    networks = {
      "10-wan0" = {
        matchConfig.Name = "wan0";

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
          { VLAN = 30; } # Cluster nodes, tagged
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
          { VLAN = 30; } # Cluster nodes, tagged
        ];
        linkConfig.RequiredForOnline = false;
      };
      "30-lan2" = {
        matchConfig.Name = "lan2";
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
          { VLAN = 30; } # Cluster nodes, tagged
        ];
        linkConfig.RequiredForOnline = false;
      };
      "40-br-lan" = {
        matchConfig.Name = "br-lan";
        bridgeConfig = { };
        # Bridge "self" port: untagged LAN for 10.0.0.1, tagged VLANs 20 and 30 for
        # the guest and cluster netdevs
        bridgeVLANs = [
          {
            PVID = 1;
            EgressUntagged = 1;
          }
          { VLAN = 20; }
          { VLAN = 30; }
        ];
        vlan = [
          "guest"
          "cluster"
        ];
        address = [
          "${lan4}.1/24"
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
        address = [ "${guest4}.1/24" ];
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
      "46-cluster" = {
        matchConfig.Name = "cluster";
        address = [ "${cluster4}.1/24" ];
        networkConfig = {
          IPv4Forwarding = true;
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
          "${vpn4}.1/24"
          "${vpn6}::1/64"
        ];
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
    "wireguard/z-fold-8/psk.key" = {
      sopsFile = ./wireguard/z-fold-8/psk.key;
      key = "data";
      mode = "0640";
      owner = "systemd-network";
      group = "systemd-network";
    };
  };
}
