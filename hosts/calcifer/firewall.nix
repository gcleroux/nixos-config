{ inventory, ... }:
let
  inherit (inventory.cidrs)
    cluster4
    cluster6
    vipPrivate4
    vipPrivate6
    ;
  inherit (inventory.hosts) totoro;
  inherit (inventory.vpnPeers) nixos-fw z-fold-8;
in
{
  networking = {
    firewall.enable = false;
    nftables = {
      enable = true;
      # IPv6 comes from EBOX (SLAAC on ebox0, a /56 by DHCPv6-PD)
      # IPv6 is routed, not NATed
      ruleset = ''
        # Zones: every interface is listed exactly once, here.
        define LAN     = { "br-lan" }
        define VPN     = { "wg0" }
        define WAN     = { "ebox0" }
        define GUEST   = { "guest" }
        define CLUSTER = { "cluster" }

        # Static IPs on the network
        define TOTORO       = ${totoro.lan4}

        # VPN peers with the same access as the LAN
        define VPN_ADMINS4  = { ${nixos-fw.ipv4}, ${z-fold-8.ipv4} } # nixos-fw, z-fold-8
        define VPN_ADMINS6  = { ${nixos-fw.ipv6}, ${z-fold-8.ipv6} }

        # Kubernetes network segments, following this structure
        # 10.0.30.0/24: Nodes (VLAN 30)
        # 10.0.40.0/24: LAN/VPN reachable LB IP
        define CLUSTER4     = ${cluster4}
        define CLUSTER6     = ${cluster6}
        define VIP_PRIVATE4 = ${vipPrivate4}
        define VIP_PRIVATE6 = ${vipPrivate6}

        table inet filter {
            chain input {
                type filter hook input priority filter; policy drop;

                iif "lo" accept
                ct state vmap { established : accept, related : accept, invalid : drop }

                iifname $LAN accept
                iifname $VPN jump input_vpn
                iifname $GUEST jump input_guest
                iifname $CLUSTER jump input_cluster
                iifname $WAN jump input_wan
                jump handle_reject
            }

            # Other VPN peers only get DNS from the router
            chain input_vpn {
                ip saddr $VPN_ADMINS4 accept
                ip6 saddr $VPN_ADMINS6 accept
                udp dport 53 accept comment "DNS"
                tcp dport 53 accept comment "DNS"
                icmp type echo-request accept
                icmpv6 type echo-request accept
                jump handle_reject
            }

            chain input_guest {
                udp dport { 53, 67 } accept comment "DNS, DHCP"
                tcp dport 53 accept comment "DNS"
                icmp type echo-request accept
                icmpv6 type { echo-request, nd-router-solicit, nd-neighbor-solicit, nd-neighbor-advert } accept
                jump handle_reject
            }

            chain input_cluster {
                udp dport 53 accept comment "DNS"
                tcp dport 53 accept comment "DNS"
                ip saddr $CLUSTER4 tcp dport 179 accept comment "BGP from the nodes (BIRD)"
                ip6 saddr $CLUSTER6 tcp dport 179 accept comment "BGP from the nodes (BIRD)"
                tcp dport 9100-9103 accept comment "Metrics: node-exporter, unbound, blocky, dnsmasq"
                ip saddr $CLUSTER4 tcp dport { 9091, 17170 } accept comment "Authelia, LLDAP web UI (private gateway)"
                icmp type echo-request accept
                icmpv6 type { echo-request, nd-router-solicit, nd-neighbor-solicit, nd-neighbor-advert } accept
                jump handle_reject
            }

            chain input_wan {
                tcp flags syn / fin,syn,rst,ack limit rate over 25/second burst 50 packets drop comment "SYN flood"
                udp dport 546 ip6 saddr fe80::/10 accept comment "DHCPv6-PD replies (ebox0)"
                udp dport 51820 accept comment "WireGuard"
                icmp type echo-request accept
                icmpv6 type { echo-request, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert } accept
                jump handle_reject
            }

            chain forward {
                type filter hook forward priority filter; policy drop;

                ct state vmap { established : accept, related : accept, invalid : drop }

                iifname $LAN oifname $WAN accept
                iifname $VPN oifname $WAN accept comment "Full tunnel to the Internet"
                iifname $VPN oifname $LAN ip saddr $VPN_ADMINS4 accept
                iifname $VPN oifname $LAN ip6 saddr $VPN_ADMINS6 accept
                iifname $GUEST oifname $WAN accept
                iifname $CLUSTER oifname $WAN accept comment "Nodes and pods to the Internet"
                iifname $CLUSTER oifname $LAN ip daddr $TOTORO tcp dport 2049 accept comment "NFS (kubelet mounts)"
                iifname $CLUSTER oifname $LAN ip daddr $TOTORO tcp dport 9100 accept comment "Metrics: totoro's node-exporter"
                iifname $LAN oifname $CLUSTER jump forward_lan_cluster
                iifname $VPN oifname $CLUSTER jump forward_vpn_cluster
                iifname $WAN oifname $LAN jump forward_wan
                jump handle_reject
            }

            # LAN and VPN_ADMINS: admin access to the nodes and the private gateway's VIPs
            chain forward_lan_cluster {
                ip daddr $CLUSTER4 tcp dport { 22, 6443 } accept comment "ssh, Kubernetes API"
                ip6 daddr $CLUSTER6 tcp dport { 22, 6443 } accept comment "ssh, Kubernetes API"
                ip daddr $VIP_PRIVATE4 tcp dport { 80, 443 } accept comment "private gateway"
                ip6 daddr $VIP_PRIVATE6 tcp dport { 80, 443 } accept comment "private gateway"
                ip daddr $CLUSTER4 icmp type echo-request accept
                ip6 daddr $CLUSTER6 icmpv6 type echo-request accept
            }

            # Other VPN peers only reach the apps, through the private gateway
            chain forward_vpn_cluster {
                ip saddr $VPN_ADMINS4 jump forward_lan_cluster
                ip6 saddr $VPN_ADMINS6 jump forward_lan_cluster
                ip daddr $VIP_PRIVATE4 tcp dport 443 accept comment "private gateway"
                ip6 daddr $VIP_PRIVATE6 tcp dport 443 accept comment "private gateway"
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

  # The nftables ruleset above decides who reaches sshd, even if the NixOS firewall is enabled later
  services.openssh.openFirewall = false;
}
