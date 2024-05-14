{
  config,
  pkgs,
  lib,
  username,
  ...
}:
{
  services.greetd = {
    enable = true;
    restart = false;
    settings = rec {
      initial_session = {
        command = ''
          ${lib.makeBinPath [ pkgs.greetd.tuigreet ]}/tuigreet --remember --asterisks --time \
            --cmd "${pkgs.river}/bin/river &> /dev/null"
        '';
        user = username;
      };
      default_session = initial_session;
    };
  };
}
