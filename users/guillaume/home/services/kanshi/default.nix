{
  # Scales are multiples of 1/8 so they stay exact for both wlr-output-management
  # (1/256) and fractional-scale-v1 (1/120). Positions are in logical pixels,
  # e.g. 3840 / 1.625 = 2363 for the Dells.
  services.kanshi = {
    enable = true;
    systemdTarget = "river-session.target";
    settings = [
      {
        profile = {
          name = "undocked";
          outputs = [
            {
              criteria = "eDP-1";
              mode = "1920x1200";
              position = "0,0";
              scale = 1.0;
              adaptiveSync = false;
            }
          ];
        };
      }
      {
        profile = {
          name = "docked";
          outputs = [
            {
              criteria = "Dell Inc. DELL S2721QS FQ0FM43";
              mode = "3840x2160";
              position = "0,0";
              scale = 1.625;
              adaptiveSync = false;
            }
            {
              criteria = "Dell Inc. DELL S2721QS 7Q1FM43";
              mode = "3840x2160";
              position = "2363,0";
              scale = 1.625;
              adaptiveSync = false;
            }
            # Bottom-aligned with the Dells: 1329 - 800
            {
              criteria = "eDP-1";
              mode = "1920x1200";
              position = "4726,529";
              scale = 1.5;
              adaptiveSync = false;
            }
          ];
        };
      }
    ];
  };
}
