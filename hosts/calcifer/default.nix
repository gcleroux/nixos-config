{ pkgs, inventory, ... }:
let
  inherit (inventory.cidrs) lan4 lan6;
  inherit (inventory.vpnPeers) nixos-fw;
in
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

  services.resolved.enable = false;

  # deploy-rs logs in as root: key only, from the LAN or nixos-fw's VPN address
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  users.users.root.openssh.authorizedKeys.keys = [
    ''from="${lan4},${lan6},${nixos-fw.ipv4},${nixos-fw.ipv6}" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICS77iyKWFPGfozY/N0daz6d9uEXhpdSVpsTTIkBbcRg guillaume@nixos-fw''
  ];

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
