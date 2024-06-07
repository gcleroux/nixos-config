{ config, pkgs, ... }:
{
  programs.virt-manager.enable = true;

  virtualisation = {
    # Enable docker
    docker = {
      enable = true;
      storageDriver = "btrfs";
    };
    # Enable KVM virtualisation
    libvirtd.enable = true;
  };
}
