{ config, pkgs, ... }:
let
  # TODO: Revert to nixos-unstable when merged
  # Fix for https://github.com/NixOS/nixpkgs/issues/328909
  ddcci-driver = config.boot.kernelPackages.ddcci-driver.overrideAttrs (oldAttrs: {
    patches = oldAttrs.patches ++ [
      (pkgs.fetchpatch {
        name = "fix-build-with-linux610.patch";
        url = "https://gitlab.com/ddcci-driver-linux/ddcci-driver-linux/-/merge_requests/16.patch";
        hash = "sha256-PapgP4cE2+d+YbNSEd6mQRvnumdiEfQpyR5f5Rs1YTs=";
      })
    ];
  });
in
{
  boot = {
    kernelModules = [ "ddcci_backlight" ];
    # extraModulePackages = with config.boot.kernelPackages; [ ddcci-driver ];
    extraModulePackages = [ ddcci-driver ];
  };
  hardware.i2c.enable = true;

  environment.systemPackages = with pkgs; [ ddcutil ];
}
