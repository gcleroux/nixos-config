{
  lib,
  hostname,
  inventory,
  ...
}:
let
  addr = inventory.hosts.${hostname};
  gateway = inventory.hosts.calcifer.cluster4; # router, DNS, BGP peer
in
{
  networking = {
    networkmanager = {
      enable = true;
      ensureProfiles.profiles.lan = {
        connection = {
          id = "lan";
          type = "ethernet";
          interface-name = "enp0s13f0u1";
          autoconnect-priority = 10;
        };
        ipv4 = {
          method = "manual";
          address1 = "${addr.cluster4}/24,${gateway}";
          dns = "${gateway};";
          dns-search = "lan;";
        };
        ipv6 = {
          method = "auto";
          address1 = "${addr.cluster6}/64";
          ip6-privacy = 0;
          ignore-auto-dns = true;
        };
      };
    };

    hosts = lib.mkForce { };
    extraHosts = "${addr.cluster4} ${hostname}";

    # Disable firewall for faster deployment
    firewall.enable = false;
  };
}
