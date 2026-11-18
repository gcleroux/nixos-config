{
  imports = [
    ./programs/aerc
    ./programs/apps
    ./programs/firefox
    ./programs/foot
    ./programs/imv
    ./programs/mpv
    ./programs/obs-studio
    ./programs/rbw
    ./programs/spotify-player
    ./programs/swaylock
    ./programs/thunderbird
    ./programs/vesktop
    ./programs/virt-manager
    ./programs/waybar
    ./programs/wofi
    ./programs/zathura

    ./services/blueman-applet
    ./services/cliphist
    ./services/fnott
    ./services/gpg-agent
    ./services/gromit-mpx
    ./services/mpris-proxy
    ./services/network-manager-applet
    ./services/playerctld
    ./services/swayidle

    ./wm/river
    ./default-apps.nix
  ]
  ++ import ./themes;

  home.sessionVariables = {
    BROWSER = "firefox";
    TERMINAL = "foot";

    # gcr's ssh agent only exports this to systemd's user environment, which river doesn't inherit
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gcr/ssh";
  };
}
