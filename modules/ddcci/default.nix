{ config, pkgs, ... }:
{
  boot = {
    kernelModules = [ ];
    extraModulePackages = with config.boot.kernelPackages; [ ddcci-driver ];
  };
  hardware.i2c.enable = true;

  environment.systemPackages = with pkgs; [ ddcutil ];
}
