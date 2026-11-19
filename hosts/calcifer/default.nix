{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./disks.nix
    ./interfaces.nix
    ./firewall.nix

    ./services
  ];

  host.users.guillaume.admin = true;
  host.services.node-exporter.enable = true;
  host.services.root-deploy.enable = true;

  services.resolved.enable = false;

  programs.mtr.enable = true;

  environment.systemPackages = with pkgs; [
    conntrack-tools
    dnsutils
    ethtool
    tcpdump
    traceroute
  ];

  system.stateVersion = "25.05";
}
