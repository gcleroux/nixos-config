{ pkgs, inventory, ... }:
let
  inherit (inventory.subnets) lan4 lan6;
  inherit (inventory.vpnPeers) nixos-fw;
in
{
  imports = [
    ./hardware.nix
    ./disks.nix
    ./interfaces.nix

    ./services
  ];

  host.users.guillaume = {
    admin = true;
    extraGroups = [ "kubernetes" ];
    home.enable = false;
  };

  # deploy-rs logs in as root: key only, from the LAN or nixos-fw's VPN address
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  users.users.root.openssh.authorizedKeys.keys = [
    ''from="${lan4}.0/24,${lan6}::/64,${nixos-fw.ipv4},${nixos-fw.ipv6}" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICS77iyKWFPGfozY/N0daz6d9uEXhpdSVpsTTIkBbcRg guillaume@nixos-fw''
  ];

  environment = {
    # Installed packages
    systemPackages = with pkgs; [
      bottom
      clinfo
      foot.terminfo
      fluxcd
      git
      glib
      k9s
      mesa
      mesa-demos
      neovim
      nfs-utils
      pciutils
      powerstat
      usbutils
      wget
    ];
  };

  system.stateVersion = "24.05";
}
