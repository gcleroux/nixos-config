{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./disks.nix
    ./interfaces.nix

    ./services
  ];

  host.users.guillaume.admin = true;
  host.services.node-exporter.enable = true;
  host.services.root-deploy.enable = true;

  environment.systemPackages = [ pkgs.gptfdisk ];

  system.stateVersion = "25.11";
}
