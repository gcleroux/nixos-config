{ pkgs, ... }:
let
  # The volume, brightness and lock popups (category "overlay") stay silent
  sound = pkgs.writeShellScript "dunst-sound" ''
    [ "$DUNST_CATEGORY" = overlay ] && exit 0
    exec ${pkgs.pipewire}/bin/pw-play ${./bubble.wav}
  '';

  colors = {
    background = "#2e3440";
    foreground = "#e5e9f0";
    frame_color = "#81a1c1";
    # Progress bars
    highlight = "#88c0d0";
  };
in
{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        # The compositor puts notifications on the output last used
        follow = "mouse";
        origin = "top-right";
        offset = "(10, 10)";
        width = 500;
        height = "(0, 300)";
        gap_size = 10;
        frame_width = 3;
        corner_radius = 8;
        font = "monospace 12";
        # Images (covers, screenshots) up to 128 px; dunst's built-in limit is 32
        max_icon_size = 128;
        layer = "top";
        # Notifications that time out or are hidden wait here (Super+N lists them)
        history_length = 100;
      };
      urgency_low = colors // {
        timeout = 10;
      };
      urgency_normal = colors // {
        timeout = 10;
      };
      urgency_critical = colors // {
        frame_color = "#bf616a";
        timeout = 0;
      };

      # The overlay popups replace each other and are not worth keeping
      overlay = {
        category = "overlay";
        history_ignore = true;
      };
      # Shown as sent: a sender's <address> isn't markup
      mail = {
        appname = "mail";
        markup = "no";
      };
      sound = {
        appname = "*";
        script = "${sound}";
      };
    };
  };
}
