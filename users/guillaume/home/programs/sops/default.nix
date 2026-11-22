{ pkgs, ... }:
{
  home.packages = with pkgs; [
    age
    age-plugin-yubikey
    sops
    ssh-to-age
  ];
}
