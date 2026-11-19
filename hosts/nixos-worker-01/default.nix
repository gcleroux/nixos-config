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
    fluxcd
    k9s
  ];

  system.stateVersion = "24.05";
}
