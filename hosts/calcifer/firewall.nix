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
    nftables = {
      enable = true;
      # IPv4 only: calcifer has no IPv6 addresses or routes. Enabling IPv6 needs
      # ICMPv6 (neighbour discovery, path MTU) and DHCPv6 rules on the WAN first.
      ruleset = ''
        # Zones: every interface is listed exactly once, here.
        define LAN   = { "br-lan", "wg0" }
        define GUEST = { "guest" }
        define WAN   = { "wan0", "ebox0" }

        table inet filter {
            chain input {
                type filter hook input priority filter; policy drop;

                iif "lo" accept
                ct state vmap { established : accept, related : accept, invalid : drop }

                iifname $LAN accept
                iifname $GUEST jump input_guest
                iifname $WAN jump input_wan
                jump handle_reject
            }

            chain input_guest {
                udp dport { 53, 67 } accept comment "DNS, DHCP"
                tcp dport 53 accept comment "DNS"
                icmp type echo-request accept
                jump handle_reject
            }

            chain input_wan {
                tcp flags syn / fin,syn,rst,ack limit rate over 25/second burst 50 packets drop comment "SYN flood"
                udp dport 68 accept comment "DHCP renewals (wan0)"
                udp dport 51820 accept comment "WireGuard"
                icmp type echo-request accept
                jump handle_reject
            }

            chain forward {
                type filter hook forward priority filter; policy drop;

                ct state vmap { established : accept, related : accept, invalid : drop }

                iifname $LAN oifname $LAN accept comment "LAN <-> VPN clients"
                iifname $LAN oifname $WAN accept
                iifname $GUEST oifname $WAN accept
                jump handle_reject
            }

            chain handle_reject {
                counter
                meta l4proto tcp reject with tcp reset
                reject
            }

            chain mangle_forward {
                type filter hook forward priority mangle; policy accept;
                tcp flags syn tcp option maxseg size set rt mtu comment "MSS clamping for the PPPoE WAN (MTU 1492)"
            }

            chain postrouting {
                type nat hook postrouting priority srcnat; policy accept;
                oifname $WAN masquerade
            }
        }
      '';
    };
  };
}
