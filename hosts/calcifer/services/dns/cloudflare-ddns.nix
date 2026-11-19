{ config, ... }:
{
  services.cloudflare-ddns = {
    enable = true;
    recordComment = "Cloudflare-ddns public IP update";
    # WireGuard needs the real IP: Cloudflare's proxy only carries HTTP(S)
    proxied = "false";
    provider.ipv6 = "none";
    ip4Domains = [
      "vpn.cleroux.dev"
    ];
    credentialsFile = config.sops.secrets."cloudflare-ddns/cf-api-token".path;
  };
  # Read by systemd as the unit's EnvironmentFile, so root ownership is enough
  sops.secrets."cloudflare-ddns/cf-api-token" = {
    sopsFile = ./cf-api-token;
    format = "binary";
  };
}
