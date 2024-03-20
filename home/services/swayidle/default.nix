{ pkgs, ... }:
let
  notify = ''
    ${pkgs.libnotify}/bin/notify-send -h string:x-canonical-private-synchronous:sys-notify -u low -c "overlay" "Locking system in 1 minute"'';
  lock = "${pkgs.swaylock}/bin/swaylock";
  # dpmsOff = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
  # dpmsOn = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
  sleep = "${pkgs.systemd}/bin/systemctl suspend";
in {
  services.swayidle = {
    enable = true;
    systemdTarget = "river-session.target";
    timeouts = [
      {
        timeout = 240;
        command = notify;
      }
      {
        timeout = 300;
        command = lock;
      }
      # {
      #   timeout = 360;
      #   command = dpmsOff;
      #   resumeCommand = dpmsOn;
      # }
      {
        timeout = 600;
        command = sleep;
      }
    ];
    events = [{
      event = "before-sleep";
      command = lock;
    }];
  };
}
