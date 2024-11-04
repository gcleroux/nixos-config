{ pkgs, ... }:
let
  notify = ''${pkgs.libnotify}/bin/notify-send -h string:x-canonical-private-synchronous:sys-notify -u low -c "overlay" "Locking system in 1 minute"'';
  lock = "${pkgs.swaylock}/bin/swaylock";
  dpmsOff = "${pkgs.wlopm}/bin/wlopm --off '*'";
  dpmsOn = "${pkgs.wlopm}/bin/wlopm --on '*'";
in
{
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
      {
        timeout = 420;
        command = dpmsOff;
        resumeCommand = dpmsOn;
      }
    ];
    events = [
      {
        event = "before-sleep";
        command = lock;
      }
    ];
  };
}
