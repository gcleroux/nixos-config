{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.services.virtualisation;
in
with lib;
{
  options = {
    host.services.virtualisation = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables virtualisation";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      libguestfs
    ];
    virtualisation = {
      # Enable docker
      docker = {
        enable = true;
        storageDriver = "btrfs";
      };
      # Enable KVM virtualisation
      libvirtd.enable = true;
    };
    programs.virt-manager.enable = true;
  };
}
