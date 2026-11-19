{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    libguestfs
  ];
  virtualisation = {
    docker = {
      enable = true;
      storageDriver = "btrfs";
      daemon.settings = {
        bip = "240.255.0.1/24";
        fixed-cidr = "240.255.0.0/24";
        default-address-pools = [
          {
            base = "240.255.0.0/16";
            size = 24;
          }
        ];
      };
    };
    libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };
  };
  programs.virt-manager.enable = true;
}
