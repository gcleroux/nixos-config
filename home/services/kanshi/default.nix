{
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    profiles = {
      laptop = {
        outputs = [{
          criteria = "eDP-1";
          status = "enable";
          mode = "2256x1504@60Hz";
          position = "0,0";
          scale = 1.566666;
        }];
      };
      docked = {
        outputs = [
          {
            criteria = "DP-4";
            mode = "3840x2160@60Hz";
            position = "0,0";
            scale = 1.666667;
          }
          {
            criteria = "DP-3";
            mode = "3840x2160@60Hz";
            position = "2304,0";
            scale = 1.666667;
          }
          {
            criteria = "eDP-1";
            status = "disable";
          }
        ];
      };
    };
  };
}
