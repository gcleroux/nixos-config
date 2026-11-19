{
  lib,
  hostname,
  inventory,
  ...
}:
let
  addr = inventory.hosts.${hostname};
  router = inventory.hosts.calcifer.cluster4;
in
{
  networking = {
    useNetworkd = true;
    useDHCP = false;

    # A plain resolv.conf, without systemd-resolved's 127.0.0.53 stub that pods can't reach
    nameservers = [ router ];
    search = [ "lan" ];

    hosts = lib.mkForce { };
    extraHosts = "${addr.cluster4} ${hostname}";

    # No host firewall: Cilium filters pod traffic and calcifer guards the cluster VLAN
    firewall.enable = false;
  };

  services.resolved.enable = false;
  systemd.network = {
    # Cilium installs its own routes and routing rules
    config.networkConfig = {
      ManageForeignRoutes = false;
      ManageForeignRoutingPolicyRules = false;
    };

    # The USB Ethernet adapter: its name depends on the port it's plugged into
    networks."30-lan" = {
      matchConfig.PermanentMACAddress = "4c:ea:41:67:19:c8";
      address = [
        "${addr.cluster4}/24"
        "${addr.cluster6}/64"
      ];
      gateway = [ router ];
      linkConfig.RequiredForOnline = "routable";
    };
  };
}
