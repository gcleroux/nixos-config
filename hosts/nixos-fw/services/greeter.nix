{ pkgs, ... }:
{
  services.greetd = {
    enable = true;
    restart = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet -d --time --remember --remember-session --session-wrapper '>/tmp/tuigreet-session.log 2>&1'";
        user = "greeter";
      };
    };
  };
}
