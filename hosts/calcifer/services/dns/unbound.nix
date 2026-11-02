{
  inputs,
  config,
  lib,
  pkgs,
  hostname,
  outputs,
  ...
}:
let
  gatewayIP = builtins.elemAt (lib.strings.splitString "/" (
    builtins.elemAt config.systemd.network.networks."40-br-lan".address 0
  )) 0;
  inherit (import ../../subnets.nix) lan4;
  # 10.0.0 -> 0.0.10.in-addr.arpa
  lanReverseZone =
    lib.concatStringsSep "." (lib.reverseList (lib.splitString "." lan4)) + ".in-addr.arpa";
in
{
  services = {
    prometheus.exporters.unbound = {
      enable = true;
      port = 9101;
      unbound = {
        host = "tcp://127.0.0.1:${toString config.services.unbound.settings.remote-control.control-port}";
      };
    };
    unbound = {
      enable = true;
      settings = {
        server = {
          interface = [
            "127.0.0.1"
            gatewayIP
          ];
          port = 5335;
          access-control = [
            "127.0.0.1 allow"
            "10.0.0.0/8 allow"
          ];

          harden-glue = true;
          harden-dnssec-stripped = true;
          use-caps-for-id = false;
          prefetch = true;
          edns-buffer-size = 1232;
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
          ];
        };
        auth-zone = [
          {
            name = ".";
            master = [
              "lax.xfr.dns.icann.org"
              "iad.xfr.dns.icann.org"
            ];
            url = "https://www.internic.net/domain/root.zone";
            fallback-enabled = true;
            for-downstream = false;
            for-upstream = true;
            zonefile = "root.zone";
          }
          {
            name = "arpa.";
            master = [
              "lax.xfr.dns.icann.org"
              "iad.xfr.dns.icann.org"
            ];
            url = "https://www.internic.net/domain/arpa.zone";
            fallback-enabled = true;
            for-downstream = false;
            for-upstream = true;
            zonefile = "arpa.zone";
          }
          {
            name = "in-addr.arpa.";
            master = [
              "lax.xfr.dns.icann.org"
              "iad.xfr.dns.icann.org"
            ];
            url = "https://www.internic.net/domain/in-addr.arpa.zone";
            fallback-enabled = true;
            for-downstream = false;
            for-upstream = true;
            zonefile = "in-addr.arpa.zone";
          }
          {
            name = "ip6.arpa.";
            master = [
              "lax.xfr.dns.icann.org"
              "iad.xfr.dns.icann.org"
            ];
            url = "https://www.internic.net/domain/ip6.arpa.zone";
            fallback-enabled = true;
            for-downstream = false;
            for-upstream = true;
            zonefile = "ip6.arpa.zone";
          }
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
          control-use-cert = true;
          control-port = 8953;
          control-interface = [
            "127.0.0.1"
            "::1"
          ];
        };
      };
    };
  };
}
