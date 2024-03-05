{ config, pkgs, lib, ... }: {
  services.greetd = {
    enable = true;
    restart = false;
    settings = rec {
      initial_session = {
        command = ''
          ${
            lib.makeBinPath [ pkgs.greetd.tuigreet ]
          }/tuigreet --remember --asterisks --time \
            --cmd "${pkgs.hyprland}/bin/Hyprland &> /dev/null"
        '';
        user = "guillaume";
      };
      default_session = initial_session;
    };
  };
}
