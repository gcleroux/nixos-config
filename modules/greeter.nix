{ config, pkgs, lib, ... }:
let
  runner = pkgs.writeShellScriptBin "runner" ''
    export XDG_SESSION_TYPE="wayland"
    export XDG_SESSION_DESKTOP="Hyprland"
    export XDG_CURRENT_DESKTOP="Hyprland"

    ${pkgs.dbus}/bin/dbus-run-session ${pkgs.hyprland}/bin/Hyprland &> /dev/null

    ${pkgs.hyprland}/bin/hyperctl dispatch exit
  '';
in {
  services.greetd = {
    enable = true;
    restart = false;
    settings = {
      default_session = {
        command = ''
          ${
            lib.makeBinPath [ pkgs.greetd.tuigreet ]
          }/tuigreet --remember --asterisks --time \
            --cmd ${lib.getExe runner}
        '';
      };
    };
  };
}
