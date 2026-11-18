{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fusee-nano
  ];
}
