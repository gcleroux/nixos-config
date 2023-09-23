{
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    profiles = {
      laptop = {
        outputs = [{
          criteria = "eDP-1";
          mode = "2256x1504@60Hz";
          position = "0,0";
          scale = 1.5;
        }];
      };
      docked_on = {
        outputs = [
          # Ideally, eDP-1 would be disabled. But Hyprland will crash if there's no display active.
          # This happens when going from docked to laptop. Might be fixed at some point.
          # In the meantime, use dpon/dpoff to enable/disable eDP-1.
          {
            criteria = "eDP-1";
            mode = "2256x1504@60Hz";
            position = "3300,1234";
            scale = 1.5;
          }
          {
            criteria = "DP-4";
            mode = "3840x2160@60Hz";
            position = "0,0";
            scale = 1.75;
          }
          {
            criteria = "DP-3";
            mode = "3840x2160@60Hz";
            position = "2194,0";
            scale = 1.75;
          }
        ];
      };
      docked_off = {
        outputs = [
          {
            criteria = "DP-4";
            mode = "3840x2160@60Hz";
            position = "0,0";
            scale = 1.75;
          }
          {
            criteria = "DP-3";
            mode = "3840x2160@60Hz";
            position = "2194,0";
            scale = 1.75;
          }
        ];
      };
    };
  };
}
