{ lib, ... }:
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
    fsType = "none";
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
    fsType = "none";
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
    fsType = "none";
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
    fsType = "none";
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
    fsType = "none";
    options = [ "bind" ];
  };

  services.nfs.server.enable = true;
  services.nfs.server.exports =
    let
      # Allowed NFS clients
      trusted =
        opts:
        lib.concatMapStringsSep " " (client: "${client}(${opts})") [
          "10.0.0.0/24" # LAN
          "10.0.9.101" # nixos-fw VPN
          "2606:6d00:ffb:6609::101" # nixos-fw VPN
        ];
      # The Kubernetes nodes on VLAN 30
      cluster = opts: "10.0.30.0/24(${opts})";
    in
    ''
      /export            ${trusted "rw,nohide,insecure,no_subtree_check,crossmnt,fsid=0"} ${cluster "ro,no_subtree_check,fsid=0"}
      /export/Appdata    ${trusted "rw,nohide,insecure,no_subtree_check,no_root_squash"} ${cluster "rw,nohide,no_subtree_check,no_root_squash"}
      /export/Documents  ${trusted "rw,nohide,insecure,no_subtree_check,no_root_squash"} ${cluster "rw,nohide,no_subtree_check,no_root_squash"}
      /export/Movies     ${trusted "rw,nohide,insecure,no_subtree_check"} ${cluster "ro,nohide,no_subtree_check"}
      /export/Photos     ${trusted "rw,nohide,insecure,no_subtree_check"} ${cluster "rw,nohide,no_subtree_check"}
      /export/Shows      ${trusted "rw,nohide,insecure,no_subtree_check"} ${cluster "ro,nohide,no_subtree_check"}
    '';
}
