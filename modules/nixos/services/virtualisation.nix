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
        daemon.settings = {
          bip = "240.255.0.1/24";
          fixed-cidr = "240.255.0.0/24";
        };
      };
      # Enable KVM virtualisation
      libvirtd = {
        enable = true;
        qemu.swtpm.enable = true;
      };
    };
    programs.virt-manager.enable = true;
  };
}
