let
  more = _: {
    services.blueman-applet.enable = true;
    services.playerctld.enable = true;
  };
in
[
  ./cliphist
  ./gpg-agent
  ./gromit-mpx
  ./mako
  ./kanshi
  ./swayidle
  more
]
