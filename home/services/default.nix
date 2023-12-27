let
  more = _: {
    services.gnome-keyring = {
      enable = true;
      components = [ "pkcs11" "secrets" "ssh" ];
    };
  };
in [ ./gpg-agent ./gromit-mpx ./kanshi ./mako ./mopidy ./swayidle more ]
