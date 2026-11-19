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
  # Hourly snapshots of the app volumes and k3s's state, pulled nightly by totoro
  host.services.btrbk-source = {
    enable = true;
    subvolumes = {
      "@appdata" = "appdata";
      "@k3s-server" = "k3s-server";
    };
  };

  environment.systemPackages = with pkgs; [
    fluxcd
    k9s
  ];

  system.stateVersion = "24.05";
}
