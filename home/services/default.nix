let
  more = _: {
    services.blueman-applet.enable = true;
    services.playerctld.enable = true;
    services.swaync.enable = true;
    services.network-manager-applet.enable = true;
    services.mpris-proxy.enable = true;
    services.gnome-keyring = {
      enable = true;
      components = [
        "pkcs11"
        "secrets"
        "ssh"
      ];
    };
  };
in
[
  ./cliphist
  # ./gpg-agent
  ./gromit-mpx
  # ./mako
  ./kanshi
  ./swayidle
  more
]
