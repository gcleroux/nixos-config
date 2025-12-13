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
      ruleset = ''
        table inet fw4 {
            chain input {
                type filter hook input priority filter; policy drop;

                iifname "lo" accept comment "!fw4: Accept traffic from loopback"
                ct state established,related accept comment "!fw4: Allow inbound established and related flows"
                tcp flags syn / fin,syn,rst,ack jump syn_flood comment "!fw4: Rate limit TCP syn packets"
                iifname { "vpn", "br-lan" } jump input_lan comment "!fw4: Handle lan IPv4/IPv6 input traffic"
                iifname "wan0" jump input_wan comment "!fw4: Handle wan IPv4/IPv6 input traffic"
                jump handle_reject
            }

            chain forward {
                type filter hook forward priority filter; policy drop;

                ct state established,related accept comment "!fw4: Allow forwarded established and related flows"
                iifname { "vpn", "br-lan" } jump forward_lan comment "!fw4: Handle lan IPv4/IPv6 forward traffic"
                iifname "wan0" jump forward_wan comment "!fw4: Handle wan IPv4/IPv6 forward traffic"
                jump handle_reject
            }

            chain output {
                type filter hook output priority filter; policy accept;
                
                oifname "lo" accept comment "!fw4: Accept traffic towards loopback"
                ct state established,related accept comment "!fw4: Allow outbound established and related flows"
                oifname { "vpn", "br-lan" } jump output_lan comment "!fw4: Handle lan IPv4/IPv6 output traffic"
                oifname "wan0" jump output_wan comment "!fw4: Handle wan IPv4/IPv6 output traffic"
            }

            chain prerouting {
                type filter hook prerouting priority filter; policy accept;

                iifname { "vpn", "br-lan" } jump helper_lan comment "!fw4: Handle lan IPv4/IPv6 helper assignment"
            }

            chain handle_reject {
                meta l4proto tcp reject with tcp reset comment "!fw4: Reject TCP traffic"
                reject comment "!fw4: Reject any other traffic"
            }

            chain syn_flood {
                limit rate 25/second burst 50 packets return comment "!fw4: Accept SYN packets below rate-limit"
                drop comment "!fw4: Drop excess packets"
            }

            chain input_lan {
                jump accept_from_lan
            }

            chain output_lan {
                jump accept_to_lan
            }

            chain forward_lan {
                jump accept_to_wan comment "!fw4: Accept lan to wan forwarding"
                jump accept_to_lan
            }

            chain helper_lan {
            }

            chain accept_from_lan {
                iifname { "vpn", "br-lan" } counter accept comment "!fw4: accept lan IPv4/IPv6 traffic"
            }

            chain accept_to_lan {
                oifname { "vpn", "br-lan" } counter  accept comment "!fw4: accept lan IPv4/IPv6 traffic"
            }

            chain input_wan {
                meta nfproto ipv4 udp dport 68 counter accept comment "!fw4: Allow-DHCP-Renew"

                icmp type echo-request counter  accept comment "!fw4: Allow-Ping"
                meta nfproto ipv4 meta l4proto igmp counter accept comment "!fw4: Allow-IGMP"
                meta nfproto ipv6 udp dport 546 counter accept comment "!fw4: Allow-DHCPv6"
                ip6 saddr fe80::/10 icmpv6 type . icmpv6 code { mld-listener-query . no-route, mld-listener-report . no-route, mld-listener-done . no-route, mld2-listener-report . no-route } counter accept comment "!fw4: Allow-MLD"
                icmpv6 type { destination-unreachable, time-exceeded, echo-request, echo-reply, nd-router-solicit, nd-router-advert } limit rate 1000/second counter accept comment "!fw4: Allow-ICMPv6-Input"
                icmpv6 type . icmpv6 code { packet-too-big . no-route, parameter-problem . no-route, nd-neighbor-solicit . no-route, nd-neighbor-advert . no-route, parameter-problem . admin-prohibited } limit rate 1000/second counter accept comment "!fw4: Allow-ICMPv6-Input"
                udp dport 51820 counter accept comment "!fw4: Allow-WireGuard"
                jump reject_from_wan
            }

            chain output_wan {
                jump accept_to_wan
            }

            chain forward_wan {
                icmpv6 type { destination-unreachable, time-exceeded, echo-request, echo-reply } limit rate 1000/second counter accept comment "!fw4: Allow-ICMPv6-Forward"
                icmpv6 type . icmpv6 code { packet-too-big . no-route, parameter-problem . no-route, parameter-problem . admin-prohibited } limit rate 1000/second counter accept comment "!fw4: Allow-ICMPv6-Forward"
                meta l4proto esp counter jump accept_to_lan comment "!fw4: Allow-IPSec-ESP"
                udp dport 500 counter jump accept_to_lan comment "!fw4: Allow-ISAKMP"
                jump reject_to_wan
            }

            chain accept_to_wan {
                meta nfproto ipv4 oifname "wan0" ct state invalid counter drop comment "!fw4: Prevent NAT leakage"
                oifname "wan0" counter accept comment "!fw4: accept wan IPv4/IPv6 traffic"
            }

            chain reject_from_wan {
                iifname "wan0" counter jump handle_reject comment "!fw4: reject wan IPv4/IPv6 traffic"
            }

            chain reject_to_wan {
                oifname "wan0" counter jump handle_reject comment "!fw4: reject wan IPv4/IPv6 traffic"
            }

            chain dstnat {
                type nat hook prerouting priority dstnat; policy accept;
            }

            chain srcnat {
                type nat hook postrouting priority srcnat; policy accept;

                oifname "wan0" jump srcnat_wan comment "!fw4: Handle wan IPv4/IPv6 srcnat traffic"
            }

            chain srcnat_wan {
                meta nfproto ipv4 masquerade comment "!fw4: Masquerade IPv4 wan traffic"
            }

            chain raw_prerouting {
                type filter hook prerouting priority raw; policy accept;
            }

            chain raw_output {
                type filter hook output priority raw; policy accept;
            }

            chain mangle_prerouting {
                type filter hook prerouting priority mangle; policy accept;
            }

            chain mangle_postrouting {
                type filter hook postrouting priority mangle; policy accept;
            }

            chain mangle_input {
                type filter hook input priority mangle; policy accept;
            }

            chain mangle_output {
                type route hook output priority mangle; policy accept;
            }

            chain mangle_forward {
                type filter hook forward priority mangle; policy accept;
                iifname "wan0" tcp flags syn tcp option maxseg size set rt mtu comment "!fw4: Zone wan IPv4/IPv6 ingress MTU fixing"
                oifname "wan0" tcp flags syn tcp option maxseg size set rt mtu comment "!fw4: Zone wan IPv4/IPv6 egress MTU fixing"
            }
        }
      '';
    };
  };
}
