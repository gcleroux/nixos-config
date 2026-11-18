{ pkgs, ... }:
{
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 28800;
    pinentry.package = pkgs.pinentry-gnome3;
  };
}
