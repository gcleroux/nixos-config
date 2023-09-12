{ pkgs, ... }: {
  # For some reason, swayidle through
  # hyprctl not working inside shell
  xdg.configFile = {
    # This config locks screen after 10 min
    # and suspend after 15 min
    "swayidle/config".text = ''
      lock "swaylock -f -C ~/.config/swaylock/config"
      before-sleep "loginctl lock-session"
      timeout 600 "loginctl lock-session"
      timeout 900 "systemctl suspend"
    '';
  };

  # Swayidle need to be installed manually
  home.packages = [ pkgs.swayidle ];

  # services.swayidle = {
  # enable = true;
  # systemdTarget = "hyprland-session.target";
  # events = [
  # {
  # event = "before-sleep";
  # command = "swaylock -f -c 000000";
  # }
  # {
  # event = "lock";
  # command = "swaylock -f -c 000000";
  # }
  # ];
  # timeouts = [
  # {
  # timeout = 10;
  # command = "swaylock -f -c 000000";
  # }
  # {
  # timeout = 60;
  # command = "systemctl suspend";
  # }
  # ];
  # };
}
