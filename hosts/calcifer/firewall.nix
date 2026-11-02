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
      # IPv6 comes from EBOX only (SLAAC on ebox0, a /56 by DHCPv6-PD). It is
      # routed, not NATed: LAN hosts are reachable wherever forward_wan allows.
      # ICMPv6 errors (packet-too-big, ...) are accepted as ct state related.
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
                icmpv6 type { echo-request, nd-router-solicit, nd-neighbor-solicit, nd-neighbor-advert } accept
                jump handle_reject
            }

            chain input_wan {
                tcp flags syn / fin,syn,rst,ack limit rate over 25/second burst 50 packets drop comment "SYN flood"
                udp dport 68 accept comment "DHCP renewals (wan0)"
                udp dport 546 ip6 saddr fe80::/10 accept comment "DHCPv6-PD replies (ebox0)"
                udp dport 51820 accept comment "WireGuard"
                icmp type echo-request accept
                icmpv6 type { echo-request, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert } accept
                jump handle_reject
            }

            chain forward {
                type filter hook forward priority filter; policy drop;

                ct state vmap { established : accept, related : accept, invalid : drop }

                iifname $LAN oifname $LAN accept comment "LAN <-> VPN clients"
                iifname $LAN oifname $WAN accept
                iifname $GUEST oifname $WAN accept
                iifname $WAN oifname $LAN jump forward_wan
                jump handle_reject
            }

            chain forward_wan {
                icmpv6 type echo-request accept
                # Services exposed from the /56, e.g.:
                # ip6 daddr <prefix>::20 tcp dport { 80, 443 } accept comment "nixos-worker-01"
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
                meta nfproto ipv4 oifname $WAN masquerade comment "IPv4 only, IPv6 is routed"
            }
        }
      '';
    };
  };
}
