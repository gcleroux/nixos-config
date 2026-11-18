{ pkgs, ... }:
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
  };

  host.services.root-deploy.enable = true;

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
