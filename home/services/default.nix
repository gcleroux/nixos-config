let
  more = _: {
    services.gnome-keyring = {
      enable = true;
      components = [ "pkcs11" "secrets" "ssh" ];
    };
  };
  #TODO: Fix gromit-mpx
  # Removed kanshi
in [ ./gpg-agent ./mako ./swayidle more ]
