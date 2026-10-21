{ pkgs, ... }:
{
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 28800;
    # pinentry.package = with pkgs; pinentry-gnome3;
  };

  # home.packages = [ pkgs.gcr ];
}
