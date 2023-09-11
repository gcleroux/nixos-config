{
  programs.swaylock = {
    enable = true;
    settings = { };
  };

  services.swayidle = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    events = [
      {
        event = "lock";
        command = "swaylock -C ~/.config/swaylock/config";
      }
      {
        event = "after-resume";
        command = "hyprctl dispatch dpms on";
      }
      {
        event = "before-sleep";
        command = "swaylock -C ~/.config/swaylock/config";
      }
    ];
    timeouts = [
      {
        timeout = 30;
        command = "swaylock -C ~/.config/swaylock/config";
      }
      {
        timeout = 60;
        command = "hyprctl dispatch dpms off";
      }
    ];
  };
}
