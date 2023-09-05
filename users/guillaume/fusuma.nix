{ pkgs, ... }: {
  services.fusuma = {
    enable = true;
    extraPackages = with pkgs; [ coreutils-full xdotool ];
    settings = {
      threshold = {
        pinch = 0.2;
        swipe = 0.2;
      };
      interval = {
        pinch = 0.5;
        swipe = 0.8;
      };
      swipe = {
        "3" = {
          "left" = {
            # Move one virtual workspace down 3-->2
            command = "xdotool key alt+Right";
          };
          "right" = {
            # Move one virtual workspace down 2-->3
            command = "xdotool key alt+Left";
          };
        };
        "4" = {
          "up" = {
            # Move one virtual workspace down 1-->2
            command = "xdotool key ctrl+alt+Down";
          };
          "down" = {
            # Move one virtual workspace down 2-->1
            command = "xdotool key ctrl+alt+Up";
          };
        };
      };
      pinch = {
        "2" = {
          "in" = { command = "xdotool keydown ctrl click 4 keyup ctrl"; };
          "out" = { command = "xdotool keydown ctrl click 5 keyup ctrl"; };
        };
      };
    };
  };
}
