{
  services.blocky = {
    enable = true;
    settings = {
      ports = {
        dns = 53;
        http = 9102; # Used by metrics exporter
      };
      prometheus = {
        enable = true;
        path = "/metrics";
      };
      upstreams.groups.default = [
        "127.0.0.1:5335"
      ];
      bootstrapDns = [
        "127.0.0.1:5335"
      ];
      caching = {
        minTime = "5m";
        maxTime = "30m";
        prefetching = true;
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
}
