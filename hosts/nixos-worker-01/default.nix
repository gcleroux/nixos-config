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

  environment.systemPackages = with pkgs; [
    clinfo
    fluxcd
    glib
    k9s
    mesa
    mesa-demos
  ];

  system.stateVersion = "24.05";
}
