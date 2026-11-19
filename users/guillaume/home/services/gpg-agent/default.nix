{ pkgs, ... }:
{
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 28800;
    pinentry.package = pkgs.pinentry-gnome3;
  };

  # Only hosts with this profile have the GPG key; signing elsewhere would fail every commit
  programs.git.signing = {
    format = "openpgp";
    signByDefault = true;
    key = "32330E3EDCF4D898";
  };
}
