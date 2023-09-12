{ pkgs, ... }: {

  programs.swaylock = {
    enable = true;
    settings = { };
  };

  # Swayidle need to be installed manually
  home.packages = [ pkgs.swayidle ];

  services.swayidle = {
    enable = true;
    systemdTarget = "graphical-session.target";
    events = [{
      event = "before-sleep";
      command = "swaylock -f -c 000000";
    }];
    timeouts = [
      {
        timeout = 300;
        command = "swaylock -f -c 000000";
      }
      {
        timeout = 600;
        command =
          "'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on'";
      }
    ];
  };
}
