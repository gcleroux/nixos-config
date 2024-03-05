let
  more = _: {
    services.gnome-keyring = {
      enable = true;
      components = [ "pkcs11" "secrets" "ssh" ];
    };
  };
  #TODO: Fix gromit-mpx
in [ ./gpg-agent ./mako ./kanshi ./swayidle more ]
