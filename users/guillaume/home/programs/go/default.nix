{ pkgs, ... }:
{
  home.sessionPath = [ "$HOME/go/bin" ];

  home.packages = with pkgs; [
    gnumake
    go
  ];
}
