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

        # IPv4 only for now.
        noipv6

        # Do not use ISP DNS.
        noresolvconf

        # Install a default route, but make EBOX secondary.
        defaultroute
        defaultroute-metric 200
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
