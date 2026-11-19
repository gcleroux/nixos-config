{
  # Fixed, so files (NFS, backups) keep their owner across hosts
  uid = 1000;
  sshKeys = [
    # howl; also lets deploy-rs reach howl by ssh to localhost
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICS77iyKWFPGfozY/N0daz6d9uEXhpdSVpsTTIkBbcRg guillaume@nixos-fw"
  ];
}
