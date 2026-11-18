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

  environment = {
    # Installed packages
    systemPackages = with pkgs; [
      bottom
      conntrack-tools
      dnsutils
      ethtool
      foot.terminfo
      git
      iputils
      neovim
      pciutils
      powerstat
      tcpdump
      traceroute
      usbutils
      wget
    ];
  };

  system.stateVersion = "25.05";
}
