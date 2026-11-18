{ pkgs, ... }:
{
  home.packages = with pkgs; [
    dig
    inetutils
    traceroute
  ];
}
