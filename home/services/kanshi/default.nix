{
  services.kanshi = {
    enable = true;
    systemdTarget = "river-session.target";
    settings = [
      {
        output = {
          criteria = "eDP-1";
          mode = "2256x1504@60Hz";
          position = "0,0";
          scale = 1.566666;
        };
      }
      {
        output = {
          criteria = "Dell Inc. DELL S2721QS 7Q1FM43";
          mode = "3840x2160@60Hz";
          position = "0,0";
          scale = 1.666667;
        };
      }
      {
        output = {
          criteria = "Dell Inc. DELL S2721QS FQ0FM43";
          status = "enable";
          mode = "3840x2160@60Hz";
          position = "2304,0";
          scale = 1.666667;
        };
      }
      {
        profile = {
          name = "undocked";
          outputs = [
            {
              criteria = "eDP-1";
            }
          ];
        };
      }
      {
        profile = {
          name = "docked";
          outputs = [
            {
              criteria = "eDP-1";
              status = "disable";
            }
            {
              criteria = "Dell Inc. DELL S2721QS 7Q1FM43";
            }
            {
              criteria = "Dell Inc. DELL S2721QS FQ0FM43";
            }
          ];
        };
      }
    ];
  };
}
