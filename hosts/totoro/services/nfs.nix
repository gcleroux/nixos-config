{
  fileSystems."/srv/Movies" = {
    device = "/dev/disk/by-id/ata-ST4000VN008-2DR166_ZDHAL4NL";
    fsType = "btrfs";
    options = [
      "users"
      "nofail"
      "rw"
      "noatime"
      "compress=zstd"
      "subvol=@movies"
    ];
  };
  fileSystems."/export/Movies" = {
    device = "/srv/Movies";
    options = [ "bind" ];
  };

  fileSystems."/srv/Shows" = {
    device = "/dev/disk/by-id/ata-ST4000VN008-2DR166_ZDHAL4NL";
    fsType = "btrfs";
    options = [
      "users"
      "nofail"
      "rw"
      "noatime"
      "compress=zstd"
      "subvol=@shows"
    ];
  };
  fileSystems."/export/Shows" = {
    device = "/srv/Shows";
    options = [ "bind" ];
  };

  fileSystems."/srv/Photos" = {
    device = "/dev/disk/by-id/ata-ST4000VN008-2DR166_ZDHAL4NL";
    fsType = "btrfs";
    options = [
      "users"
      "nofail"
      "rw"
      "noatime"
      "compress=zstd"
      "subvol=@photos"
    ];
  };
  fileSystems."/export/Photos" = {
    device = "/srv/Photos";
    options = [ "bind" ];
  };

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /export         10.0.0.0/24(rw,nohide,insecure,no_subtree_check,crossmnt,fsid=0)
    /export/Movies  10.0.0.0/24(rw,nohide,insecure,no_subtree_check)
    /export/Shows   10.0.0.0/24(rw,nohide,insecure,no_subtree_check)
    /export/Photos  10.0.0.0/24(rw,nohide,insecure,no_subtree_check)
  '';
}
