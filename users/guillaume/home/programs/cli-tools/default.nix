{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fd
    jq
    killall
    yq-go
  ];
}
