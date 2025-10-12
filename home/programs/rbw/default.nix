{ pkgs, ... }:
{
  programs.rbw = {
    enable = true;
    settings = {
      email = "guillaume@cleroux.dev";
      base_url = "https://vaultwarden.cleroux.dev/";
      lock_timeout = 3600;
      pinentry = pkgs.pinentry-gnome3;
    };
  };
}
