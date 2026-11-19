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
    ./programs/swaylock
    ./programs/vesktop
    ./programs/virt-manager
    ./programs/waybar
    ./programs/zathura

    ./services/blueman-applet
    ./services/cliphist
    ./services/fnott
    ./services/gpg-agent
    ./services/kanshi
    ./services/mpris-proxy
    ./services/network-manager-applet
    ./services/playerctld
    ./services/polkit-gnome
    ./services/swayidle

    ./wm/river
    ./default-apps.nix
    ./themes
  ];

  home.sessionVariables = {
    BROWSER = "firefox";
    TERMINAL = "foot";

    # gcr's ssh agent only exports this to systemd's user environment, which river doesn't inherit
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gcr/ssh";
  };
}
