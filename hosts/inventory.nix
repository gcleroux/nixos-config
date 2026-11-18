# Network facts shared across hosts, passed to every host as `inventory`.
# IPv6 subnets are coming from ebox static /56 and divided into /64
let
  cidrs = {
    lan4 = "10.0.0.0/24";
    lan6 = "2606:6d00:ffb:6600::/64";

    # Guest subnet, no static IPv6
    guest4 = "10.0.20.0/24";

    # Wireguard subnet
    vpn4 = "10.0.9.0/24";
    vpn6 = "2606:6d00:ffb:6609::/64";

    # Cluster subnet, VLAN.30
    cluster4 = "10.0.30.0/24";
    cluster6 = "2606:6d00:ffb:6630::/64";

    # Kubernetes LoadBalancer IPs, routed to the nodes by BGP: reachable from the LAN and VPN
    vipPrivate4 = "10.0.40.0/24";
    vipPrivate6 = "2606:6d00:ffb:6640::/64";

    # Internet-facing LoadBalancer IPs, routed to the nodes by BGP
    vipPublic4 = "10.0.50.0/24";
    vipPublic6 = "2606:6d00:ffb:6650::/64";

    # Kubernetes pod ranges, one /24 and /64 per node: IPv4 is masqueraded, IPv6 routed by BGP
    pods4 = "10.42.0.0/16";
    pods6 = "2606:6d00:ffb:6680::/60";
  };

  # Address n in a /24 or /64: ip "10.0.30.0/24" 10 = "10.0.30.10" and
  # ip "2606:6d00:ffb:6630::/64" 10 = "2606:6d00:ffb:6630::10" (the IPv6 host ID repeats the IPv4 digits)
  ip =
    cidr: n:
    let
      v4 = builtins.match "(.*)\\.0/24" cidr;
      v6 = builtins.match "(.*)::/64" cidr;
    in
    if v4 != null then
      "${builtins.head v4}.${toString n}"
    else if v6 != null then
      "${builtins.head v6}::${toString n}"
    else
      throw "ip: ${cidr} isn't a /24 or a /64";
in
{
  inherit cidrs ip;

  hosts = {
    calcifer = {
      lan4 = ip cidrs.lan4 1;
      guest4 = ip cidrs.guest4 1;
      vpn4 = ip cidrs.vpn4 1;
      vpn6 = ip cidrs.vpn6 1;
      cluster4 = ip cidrs.cluster4 1;
      cluster6 = ip cidrs.cluster6 1;
    };

    # Below calcifer's DHCP pool
    totoro = {
      lan4 = ip cidrs.lan4 2;
      lan6 = ip cidrs.lan6 2;
    };

    # Cluster node addresses start at .10 / ::10
    nixos-worker-01 = {
      cluster4 = ip cidrs.cluster4 10;
      cluster6 = ip cidrs.cluster6 10;
    };
  };

  vpnPeers =
    builtins.mapAttrs
      (_: id: {
        ipv4 = ip cidrs.vpn4 id;
        ipv6 = ip cidrs.vpn6 id;
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
