{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.services.audio;
in
with lib;
{
  options = {
    host.services.audio = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables pipewire audio server";
      };

      bluetooth = {
        enable = mkOption {
          default = false;
          type = with types; bool;
          description = "Enables Bluetooth audio support via Pipewire";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    # Pipewire config
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Bluetooth config
    services.blueman.enable = cfg.bluetooth.enable;
    hardware.bluetooth = lib.optionals cfg.bluetooth.enable {
      enable = true;
      powerOnBoot = true;
    };
    services.pipewire.wireplumber = lib.optionals cfg.bluetooth.enable {
      configPackages = [
        (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
          bluez_monitor.properties = {
              ["with-logind"] = false,
          }
        '')
      ];
      extraConfig."11-bluetooth-policy" = {
        "wireplumber.settings" = {
          "bluetooth.autoswitch-to-headset-profile" = false;
        };
      };
    };
  };
}
