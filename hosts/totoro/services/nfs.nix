{
  # Movies
  fileSystems."/srv/Movies" = {
    device = "/dev/disk/by-uuid/717530ad-efae-402a-a397-cae119b2b1d4";
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

  # Shows
  fileSystems."/srv/Shows" = {
    device = "/dev/disk/by-uuid/717530ad-efae-402a-a397-cae119b2b1d4";
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

  # Photos
  fileSystems."/srv/Photos" = {
    device = "/dev/disk/by-uuid/717530ad-efae-402a-a397-cae119b2b1d4";
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

  # App data
  fileSystems."/srv/Appdata" = {
    device = "/dev/disk/by-uuid/c711808d-120c-4c5b-9cf1-07794b061681";
    fsType = "btrfs";
    options = [
      "users"
      "nofail"
      "rw"
      "noatime"
      "compress=zstd"
      "subvol=@appdata"
    ];
  };
  fileSystems."/export/Appdata" = {
    device = "/srv/Appdata";
    options = [ "bind" ];
  };

  # Documents
  fileSystems."/srv/Documents" = {
    device = "/dev/disk/by-uuid/c711808d-120c-4c5b-9cf1-07794b061681";
    fsType = "btrfs";
    options = [
      "users"
      "nofail"
      "rw"
      "noatime"
      "compress=zstd"
      "subvol=@documents"
    ];
  };
  fileSystems."/export/Documents" = {
    device = "/srv/Documents";
    options = [ "bind" ];
  };

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /export            10.0.0.0/24(rw,nohide,insecure,no_subtree_check,crossmnt,fsid=0)
    /export/Appdata    10.0.0.0/24(rw,nohide,insecure,no_subtree_check,no_root_squash)
    /export/Documents  10.0.0.0/24(rw,nohide,insecure,no_subtree_check,no_root_squash)
    /export/Movies     10.0.0.0/24(rw,nohide,insecure,no_subtree_check)
    /export/Photos     10.0.0.0/24(rw,nohide,insecure,no_subtree_check)
    /export/Shows      10.0.0.0/24(rw,nohide,insecure,no_subtree_check)
  '';
}
