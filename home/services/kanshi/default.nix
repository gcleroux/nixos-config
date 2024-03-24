{
  services.kanshi = {
    enable = false;
    systemdTarget = "river-session.target";
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
            criteria = "Dell Inc. DELL S2721QS FQ0FM43";
            mode = "3840x2160@60Hz";
            position = "0,0";
            scale = 1.666667;
          }
          {
            criteria = "Dell Inc. DELL S2721QS 7Q1FM43";
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
