# Network facts shared across hosts, passed to every host as `inventory`.
# IPv6 subnets are coming from ebox static /56 and divided into /64
let
  subnets = {
    lan4 = "10.0.0";
    lan6 = "2606:6d00:ffb:6600";

    # Guest subnet, no static IPv6
    guest4 = "10.0.20";

    # Wireguard subnet
    vpn4 = "10.0.9";
    vpn6 = "2606:6d00:ffb:6609";

    # Cluster subnet, VLAN.30
    cluster4 = "10.0.30";
    cluster6 = "2606:6d00:ffb:6630";

    # Kubernetes LoadBalancer IPs, routed to the nodes by BGP: reachable from the LAN and VPN
    vipPrivate4 = "10.0.40";
    vipPrivate6 = "2606:6d00:ffb:6640";

    # Internet-facing LoadBalancer IPs, routed to the nodes by BGP
    vipPublic4 = "10.0.50";
    vipPublic6 = "2606:6d00:ffb:6650";
  };
in
{
  inherit subnets;

  # Kubernetes pod ranges, one /24 and /64 per node: IPv4 is masqueraded, IPv6 routed by BGP
  pods = {
    ipv4 = "10.42.0.0/16";
    ipv6 = "2606:6d00:ffb:6680::/60";
  };

  hosts = {
    calcifer = {
      lan4 = "${subnets.lan4}.1";
      guest4 = "${subnets.guest4}.1";
      vpn4 = "${subnets.vpn4}.1";
      vpn6 = "${subnets.vpn6}::1";
      cluster4 = "${subnets.cluster4}.1";
      cluster6 = "${subnets.cluster6}::1";
    };

    # Below calcifer's DHCP pool
    totoro = {
      lan4 = "${subnets.lan4}.2";
      lan6 = "${subnets.lan6}::2";
    };

    # Cluster node addresses start at .10 / ::10
    nixos-worker-01 = {
      cluster4 = "${subnets.cluster4}.10";
      cluster6 = "${subnets.cluster6}::10";
    };
  };

  vpnPeers =
    builtins.mapAttrs
      (_: id: {
        ipv4 = "${subnets.vpn4}.${toString id}";
        ipv6 = "${subnets.vpn6}::${toString id}";
      })
      {
        s24-ultra = 100;
        nixos-fw = 101;
        iphone-lapin = 102;
        mac-lapin = 103;
        s23-julie = 104;
        z-fold-8 = 105;
      };
}
