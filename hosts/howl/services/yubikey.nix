{ pkgs, ... }:
{
  services.pcscd.enable = true;

  environment.systemPackages = [ pkgs.yubikey-manager ];
}
