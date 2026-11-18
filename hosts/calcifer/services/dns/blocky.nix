{ config, ... }:
{
  services.blocky = {
    enable = true;
    settings = {
      ports = {
        dns = 53;
        # nginx below exposes only /metrics on 9102.
        http = "127.0.0.1:4000";
      };
      prometheus = {
        enable = true;
        path = "/metrics";
      };
      upstreams.groups.default = [
        "127.0.0.1:${toString config.services.unbound.settings.server.port}"
      ];
      bootstrapDns = [
        "127.0.0.1:${toString config.services.unbound.settings.server.port}"
      ];
      caching = {
        minTime = "0";
        maxTime = "-1"; # Disables blocky cache
        prefetching = false;
      };
      specialUseDomains.enable = false; # Don't block .lan TLD
      blocking = {
        denylists = {
          ads = [
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            "https://adaway.org/hosts.txt"
            "https://raw.githubusercontent.com/ProgramComputer/Easylist_hosts/refs/heads/main/hosts"
            "https://big.oisd.nl/domainswild"
          ];
          phishing = [
            "https://hole.cert.pl/domains/v2/domains.txt"
          ];
          tracking = [
            "https://raw.githubusercontent.com/ProgramComputer/Easylist_hosts/refs/heads/main/EasyListMirror/easyprivacy/easyprivacy_trackingservers_general.txt/hosts"
            "https://raw.githubusercontent.com/ProgramComputer/Easylist_hosts/refs/heads/main/EasyListMirror/easyprivacy/easyprivacy_thirdparty.txt/hosts"
            "https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/refs/heads/master/SmartTV.txt"
          ];
        };
        clientGroupsBlock = {
          default = [
            "ads"
            "phishing"
            "tracking"
          ];
        };
      };
    };
  };

  # Blocky's metrics for VictoriaMetrics, without the rest of its API
  services.nginx = {
    enable = true;
    virtualHosts.blocky-metrics = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 9102;
        }
      ];
      locations."= /metrics".proxyPass = "http://127.0.0.1:4000";
      locations."/".return = "404";
    };
  };
}
