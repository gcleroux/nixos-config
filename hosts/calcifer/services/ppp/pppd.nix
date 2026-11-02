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
  services.pppd = {
    enable = true;

    peers.ebox = {
      enable = true;
      autostart = true;

      config = ''
        # Modern pppd PPPoE plugin.
        plugin pppoe.so
        nic-ebox-wan

        # Give the resulting PPP interface a stable name.
        ifname ebox0
        linkname ebox

        user cg1320@pppoe.ebox.net
        name cg1320@pppoe.ebox.net

        # ISP-assigned IPv4 address.
        noipdefault
        ipcp-accept-local
        ipcp-accept-remote
        noauth

        # EBOX requirement.
        mtu 1492
        mru 1492

        # Keep reconnecting indefinitely.
        persist
        maxfail 0
        holdoff 5

        # Detect a dead PPP session.
        lcp-echo-interval 10
        lcp-echo-failure 3

        # IPv6CP only brings up a link-local address on ebox0; networkd does
        # SLAAC and DHCPv6-PD on top of it (see 12-ebox0 in interfaces.nix).
        +ipv6

        # Do not use ISP DNS.
        noresolvconf

        # EBOX is the only WAN: install the IPv4 default route.
        defaultroute
      '';
    };
  };

  sops.secrets."ppp/ebox-auth" = {
    sopsFile = ./ebox-auth;
    format = "binary";

    owner = "root";
    group = "root";
    mode = "0600";
  };

  environment.etc = {
    "ppp/chap-secrets".source = config.sops.secrets."ppp/ebox-auth".path;
  };
}
