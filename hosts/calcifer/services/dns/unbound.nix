{
  config,
  lib,
  inventory,
  ...
}:
let
  inherit (inventory) ip;
  inherit (inventory.cidrs) lan4 vipPrivate4 vipPrivate6;
  # 10.0.0.0/24 -> 0.0.10.in-addr.arpa
  lanReverseZone =
    lib.concatStringsSep "." (lib.reverseList (lib.take 3 (lib.splitString "." lan4)))
    + ".in-addr.arpa";

  # Every name under this zone is a hostname on the cluster's private gateway, so
  # a redirect zone answers them all without listing each one
  privateZone = "home.cleroux.dev";

  # The private gateway's VIPs, routed to the cluster by BIRD
  privateGateway4 = ip vipPrivate4 10;
  privateGateway6 = ip vipPrivate6 10;
  privateTTL = "60";
in
{
  services = {
    prometheus.exporters.unbound = {
      enable = true;
      port = 9101;
      unbound.host = "tcp://127.0.0.1:${toString config.services.unbound.settings.remote-control.control-port}";
    };
    unbound = {
      enable = true;
      settings = {
        server = {
          # Only blocky queries it, on localhost
          port = 5335;

          harden-glue = true;
          harden-dnssec-stripped = true;
          prefetch = true;
          hide-identity = true;
          hide-version = true;
          extended-statistics = true;

          # Local zone is handled by dnsmasq
          do-not-query-localhost = false;
          domain-insecure = [
            "lan"
            lanReverseZone
          ];
          private-domain = [
            "lan"
            lanReverseZone
            # Allow private IP for these domain
            "cleroux.dev"
            "pinax.io"
            "eosn.io"
          ];
          private-address = [
            "10.0.0.0/8"
            "172.16.0.0/12"
            "192.168.0.0/16"
          ];
          local-zone = [
            "lan transparent"
            "${lanReverseZone} transparent"
            "${privateZone}. redirect"
          ];
          # unbound needs local-data quoted.
          local-data = [
            ''"${privateZone}. ${privateTTL} A ${privateGateway4}"''
            ''"${privateZone}. ${privateTTL} AAAA ${privateGateway6}"''
          ];
        };
        auth-zone =
          map
            (zone: {
              name = if zone == "root" then "." else "${zone}.";
              master = [
                "lax.xfr.dns.icann.org"
                "iad.xfr.dns.icann.org"
              ];
              url = "https://www.internic.net/domain/${zone}.zone";
              fallback-enabled = true;
              for-downstream = false;
              for-upstream = true;
              zonefile = "${zone}.zone";
            })
            [
              "root"
              "arpa"
              "in-addr.arpa"
              "ip6.arpa"
            ];
        forward-zone = [
          {
            name = "lan";
            forward-first = false;
            forward-addr = "127.0.0.1@${toString config.services.dnsmasq.settings.port}";
          }
          {
            name = lanReverseZone;
            forward-first = false;
            forward-addr = "127.0.0.1@${toString config.services.dnsmasq.settings.port}";
          }
        ];
        remote-control = {
          control-enable = true;
          # The exporter above connects here
          control-port = 8953;
        };
      };
    };
  };
}
