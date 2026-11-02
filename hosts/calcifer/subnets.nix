# Calcifer's subnets, shared by the network, DHCP and DNS config.
{
  # IPv4 /24s, addresses are "${subnet}.<host>"
  lan4 = "10.0.0";
  guest4 = "10.0.20";
  vpn4 = "10.0.9";

  # VPN /64 from the EBOX /56: subnet 09 mirrors vpn4, and peer host IDs
  # mirror their IPv4 address (10.0.9.100 -> ::100). The LAN and guest /64s
  # come from DHCPv6-PD instead, see their SubnetId in interfaces.nix.
  vpn6 = "2606:6d00:ffb:6609";
}
