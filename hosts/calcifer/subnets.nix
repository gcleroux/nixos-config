# Calcifer's subnets, shared by the network, DHCP and DNS config.
# IPv6 subnets are coming from ebox static /56 and divided into /64
{
  # LAN
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
}
