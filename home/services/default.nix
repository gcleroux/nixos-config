let
  more = _: {
    services.gnome-keyring = {
      enable = true;
      components = [ "pkcs11" "secrets" "ssh" ];
    };
  };
in [ ./gpg-agent ./kanshi ./mako ./swayidle more ]
