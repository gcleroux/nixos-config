{ config, pkgs, ... }:
{
  # Bluetooth config
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;
}
