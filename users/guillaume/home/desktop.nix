{ pkgs, ... }:
{
  imports = [
    ./programs/aerc
    ./programs/firefox
    ./programs/foot
    ./programs/mpv
    ./programs/rbw
    ./programs/spotify-player
    ./programs/swaylock
    ./programs/waybar
    ./programs/wofi

    ./services/cliphist
    ./services/fnott
    ./services/gpg-agent
    ./services/gromit-mpx
    ./services/swayidle

    ./wm/river
    ./default-apps.nix
  ]
  ++ import ./themes;

  programs.imv.enable = true;

  services.blueman-applet.enable = true;
  services.playerctld.enable = true;
  services.network-manager-applet.enable = true;
  services.mpris-proxy.enable = true;

  home.sessionVariables = {
    BROWSER = "firefox";
    TERMINAL = "foot";

    # gcr's ssh agent only exports this to systemd's user environment, which river doesn't inherit
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gcr/ssh";
  };

  home.packages = with pkgs; [
    clipboard-jh
    jellyfin-desktop
    libreoffice
    lswt
    moonlight-qt
    obs-studio
    pavucontrol
    qbittorrent
    signal-desktop
    simplex-tz-fix
    slack
    spotify-player
    thunderbird-bin
    vesktop
    wbg
    way-displays
    wlr-randr
    zathura
  ];

  # TODO: Find a place for this config
  # Creating default connection for virt-manager
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };

    # https://codeberg.org/river/wiki#workaround-for-firefox
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "";
    };
  };
}
