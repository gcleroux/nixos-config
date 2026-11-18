{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jellyfin-desktop
    libreoffice
    moonlight-qt
    pavucontrol
    qbittorrent
    signal-desktop
    slack
  ];
}
