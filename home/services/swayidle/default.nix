{ pkgs, ... }:
let
  notify = ''
    ${pkgs.libnotify}/bin/notify-send -h string:x-canonical-private-synchronous:sys-notify -u low -c "overlay" "Locking system in 1 minute"'';
  lock = "${pkgs.swaylock}/bin/swaylock";
  dpmsOff = "${pkgs.custom-scripts}/bin/brightness --dpms-off";
  dpmsOn = "${pkgs.custom-scripts}/bin/brightness --dpms-on";
in {
  services.swayidle = {
    enable = false; # TODO: ddcutil breaks in home-manager service
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
      {
        timeout = 15;
        command = dpmsOff;
        resumeCommand = dpmsOn;
      }
    ];
    events = [{
      event = "before-sleep";
      command = lock;
    }];
  };
}
