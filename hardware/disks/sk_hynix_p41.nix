{
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = [
        "subvol=@"
        "compress=zstd"
        "noatime"
      ];
    };
    "/home" = {
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = [
        "subvol=@home"
        "compress=zstd"
        "noatime"
      ];
    };
    "/nix" = {
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = [
        "subvol=@nix"
        "compress=zstd"
        "noatime"
      ];
    };
    "/persist" = {
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = [
        "subvol=@persist"
        "compress=zstd"
        "noatime"
      ];
    };
    "/var/log" = {
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = [
        "subvol=@log"
        "compress=zstd"
        "noatime"
      ];
    };
    "/.snapshots" = {
      device = "/dev/mapper/root";
      fsType = "btrfs";
      options = [
        "subvol=@snapshots"
        "compress=zstd"
        "noatime"
      ];
    };
  };

  swapDevices = [ ];
}
