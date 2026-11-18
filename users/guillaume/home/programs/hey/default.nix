{ pkgs, ... }:
{
  home.packages = with pkgs; [
    hey
  ];
}
