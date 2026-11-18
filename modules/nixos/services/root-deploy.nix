{
  config,
  lib,
  inventory,
  ...
}:
let
  inherit (inventory.cidrs) lan4 lan6;
  inherit (inventory.vpnPeers) nixos-fw;
in
{
  options.host.services.root-deploy.enable = lib.mkEnableOption "root SSH logins for deploy-rs";

  # deploy-rs logs in as root: key only, from the LAN or nixos-fw's VPN address
  config = lib.mkIf config.host.services.root-deploy.enable {
    services.openssh.settings.PermitRootLogin = "prohibit-password";
    users.users.root.openssh.authorizedKeys.keys = [
      ''from="${lan4},${lan6},${nixos-fw.ipv4},${nixos-fw.ipv6}" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICS77iyKWFPGfozY/N0daz6d9uEXhpdSVpsTTIkBbcRg guillaume@nixos-fw''
    ];
  };
}
