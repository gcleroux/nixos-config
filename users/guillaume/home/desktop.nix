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

    ./services/batsignal
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
    ./services/wbg

    ./wm/river
    ./default-apps
    ./themes
  ];

  home.sessionVariables = {
    BROWSER = "firefox";
    TERMINAL = "foot";
  };
}
