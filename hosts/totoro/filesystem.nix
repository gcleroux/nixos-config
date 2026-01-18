{
  fileSystems."/srv/Media" = {
    device = "/dev/disk/by-id/ata-ST4000VN008-2DR166_ZDHAL4NL";
    fsType = "btrfs";
    options = [
      "users"
      "nofail"
      "rw"
      "noatime"
      "compress=zstd"
      "subvol=@media"
    ];
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

  # NFS
  fileSystems."/export/Media" = {
    device = "/srv/Media";
    options = [ "bind" ];
  };

  fileSystems."/export/Photos" = {
    device = "/srv/Photos";
    options = [ "bind" ];
  };

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /export         10.0.0.0/24(rw,nohide,insecure,no_subtree_check,crossmnt,fsid=0)
    /export/Media   10.0.0.0/24(rw,nohide,insecure,no_subtree_check)
    /export/Photos  10.0.0.0/24(rw,nohide,insecure,no_subtree_check)
  '';
}
