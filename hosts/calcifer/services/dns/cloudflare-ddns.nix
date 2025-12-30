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
  services.cloudflare-ddns = {
    enable = true;
    recordComment = "Cloudflare-ddns public IP update";
    proxied = "false";
    provider = {
      ipv4 = "cloudflare.trace";
      ipv6 = "none";
    };
    ip4Domains = [
      "vpn.cleroux.dev"
    ];
    credentialsFile = config.sops.secrets."cloudflare-ddns/cf-api-token".path;
  };
  sops.secrets."cloudflare-ddns/cf-api-token" = {
    sopsFile = ./cf-api-token;
    key = "data";
    mode = "0400";
    owner = "cloudflare-ddns";
    group = "cloudflare-ddns";
  };
}
