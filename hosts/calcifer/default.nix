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
  # Hourly snapshots of @, pulled nightly by totoro. Only /var/lib, /etc, /tmp, /root and /srv live there
  host.services.btrbk-source = {
    enable = true;
    subvolumes."@" = "root";
  };

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
