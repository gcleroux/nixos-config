{ pkgs, ... }:
{
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    # pinentry.package = with pkgs; pinentry-gnome3;
  };

  # home.packages = [ pkgs.gcr ];
}
