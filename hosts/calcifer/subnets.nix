# Calcifer's subnets, shared by the network, DHCP and DNS config.
{
  # IPv4 /24s, addresses are "${subnet}.<host>"
  lan4 = "10.0.0";
  guest4 = "10.0.20";
  vpn4 = "10.0.9";
  cluster4 = "10.0.30"; # Kubernetes nodes on VLAN 30, from .10 up

  # VPN /64 from the EBOX /56: subnet 09 mirrors vpn4, and peer host IDs
  # mirror their IPv4 address (10.0.9.100 -> ::100). The LAN and guest /64s
  # come from DHCPv6-PD instead, see their SubnetId in interfaces.nix.
  vpn6 = "2606:6d00:ffb:6609";

  # LAN and cluster /64s, for static host addresses only. The interfaces' own
  # addresses still come from DHCPv6-PD (SubnetId 0x0 and 0x30), which hands
  # out these same static prefixes.
  lan6 = "2606:6d00:ffb:6600";
  cluster6 = "2606:6d00:ffb:6630";
}
