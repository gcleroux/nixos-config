{ lib, inventory, ... }:
let
  inherit (inventory.cidrs) lan4 cluster4;
  inherit (inventory.vpnPeers) nixos-fw;

  # Each share is the btrfs subvolume @<name> of a disk, mounted in /srv and bind-mounted into /export
  shares = {
    Appdata = "c711808d-120c-4c5b-9cf1-07794b061681";
    Documents = "c711808d-120c-4c5b-9cf1-07794b061681";
    Movies = "717530ad-efae-402a-a397-cae119b2b1d4";
    Photos = "717530ad-efae-402a-a397-cae119b2b1d4";
    Shows = "717530ad-efae-402a-a397-cae119b2b1d4";
  };
in
{
  fileSystems = lib.concatMapAttrs (name: uuid: {
    "/srv/${name}" = {
      device = "/dev/disk/by-uuid/${uuid}";
      fsType = "btrfs";
      options = [
        "users"
        "nofail"
        "rw"
        "noatime"
        "compress=zstd"
        "subvol=@${lib.toLower name}"
      ];
    };
    "/export/${name}" = {
      device = "/srv/${name}";
      fsType = "none";
      options = [ "bind" ];
    };
  }) shares;

  services.nfs.server.enable = true;
  services.nfs.server.exports =
    let
      # Allowed NFS clients
      trusted =
        opts:
        lib.concatMapStringsSep " " (client: "${client}(${opts})") [
          lan4
          nixos-fw.ipv4
          nixos-fw.ipv6
        ];
      # The Kubernetes nodes on VLAN 30
      cluster = opts: "${cluster4}(${opts})";
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
