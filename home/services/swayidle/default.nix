{ pkgs, ... }:
let
  notify = "${pkgs.libnotify}/bin/notify-send 'Locking system in 1 minute'";
  lock = "${pkgs.swaylock}/bin/swaylock";
  dpmsOff = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
  dpmsOn = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
  # Only sleep when battery is discharing, this will NOT prevent sleep while plugged in with dpms off.
  # To do this, you need logind lidSwitchExternalPower=ignore since it is not considered docked when
  # the displays are off.
  sleep = ''
    [ "$(${pkgs.bat}/bin/bat -p /sys/class/power_supply/BAT1/status)" = "Discharging" ] && ${pkgs.systemd}/bin/systemctl suspend'';
in {
  services.swayidle = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    timeouts = [
      {
        timeout = 240;
        command = notify;
      }
      {
        timeout = 300;
        command = lock;
      }
      {
        timeout = 360;
        command = dpmsOff;
        resumeCommand = dpmsOn;
      }
      {
        timeout = 900;
        command = sleep;
      }
    ];
    events = [{
      event = "before-sleep";
      command = lock;
    }];
  };
}
