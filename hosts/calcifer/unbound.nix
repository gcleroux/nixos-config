{
  services = {
    prometheus.exporters.unbound = {
      enable = true;
      unbound = {
        host = "tcp://127.0.0.1:5335";
      };
    };
    unbound = {
      enable = true;
      settings = {
        server = {
          interface = [
            "127.0.0.1"
            "192.168.0.10"
          ];
          port = 5335;
          access-control = [
            "127.0.0.1 allow"
            "192.168.0.0/8 allow"
          ];

          harden-glue = true;
          harden-dnssec-stripped = true;
          use-caps-for-id = false;
          prefetch = true;
          edns-buffer-size = 1232;
          hide-identity = true;
          hide-version = true;

          # Local zone is handled by dnsmasq
          do-not-query-localhost = false;
          domain-insecure = [
            "internal"
            "0.0.10.in-addr.arpa"
          ];
          private-domain = [
            "internal"
            "0.0.10.in-addr.arpa"
          ];
          local-zone = [
            "internal transparent"
            "0.0.10.in-addr.arpa transparent"
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
            name = "internal";
            forward-first = false;
            forward-addr = "127.0.0.1@1053";
          }
          {
            name = "0.0.10.in-addr.arpa";
            forward-first = false;
            forward-addr = "127.0.0.1@1053";
          }
        ];
        remote-control = {
          control-enable = true;
          control-use-cert = true;
          control-interface = [
            "127.0.0.1"
            "::1"
          ];
        };
      };
    };
  };
}
