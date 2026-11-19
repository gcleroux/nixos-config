let
  # Subvolumes of the btrfs filesystem inside the LUKS volume
  subvol = name: {
    device = "/dev/mapper/root";
    fsType = "btrfs";
    options = [
      "subvol=${name}"
      "compress=zstd"
      "noatime"
    ];
  };
in
{
  boot.initrd.luks.devices.root.device = "/dev/disk/by-uuid/dbed6eea-7331-4610-b531-4f78b063fb1a";

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };
    "/" = subvol "@";
    "/home" = subvol "@home";
    "/nix" = subvol "@nix";
    "/var/log" = subvol "@log";
    "/.snapshots" = subvol "@snapshots";
    "/srv/totoro" = {
      device = "totoro:/";
      fsType = "nfs";
      options = [
        "x-systemd.automount" # Lazy mounting
        "x-systemd.idle-timeout=600" # Timeout after 10m
        "noauto"
        "user"
        "_netdev"
        "bg"
      ];
    };
  };
}
