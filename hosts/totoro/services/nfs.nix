{ lib, inventory, ... }:
let
  inherit (inventory.cidrs) lan4 lan6 cluster4;
  inherit (inventory.vpnPeers) howl;

  # Each share is the btrfs subvolume @<name> of a disk, mounted in /srv and bind-mounted into /export
  shares = {
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
        "nofail"
        "noatime"
        "nosuid"
        "nodev"
        "noexec"
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
          lan6
          howl.ipv4
          howl.ipv6
        ];
      # The Kubernetes nodes on VLAN 30
      cluster = opts: "${cluster4}(${opts})";
    in
    ''
      /export            ${trusted "rw,nohide,insecure,no_subtree_check,crossmnt,fsid=0"} ${cluster "ro,no_subtree_check,fsid=0"}
      /export/Movies     ${trusted "rw,nohide,insecure,no_subtree_check"} ${cluster "ro,nohide,no_subtree_check"}
      /export/Photos     ${trusted "rw,nohide,insecure,no_subtree_check"} ${cluster "rw,nohide,no_subtree_check"}
      /export/Shows      ${trusted "rw,nohide,insecure,no_subtree_check"} ${cluster "ro,nohide,no_subtree_check"}
    '';
}
