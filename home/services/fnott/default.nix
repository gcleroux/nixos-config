{ pkgs, ... }:
{
  services.fnott = {
    enable = true;
    settings = {
      main = {
        max-width = 500;
        max-height = 300;
        anchor = "top-right";
        stacking-order = "top-down";
        layer = "top";
        play-sound = "${pkgs.pipewire}/bin/pw-play \${filename}";
        sound-file = "${./bubble.wav}";

        edge-margin-vertical = 10;
        edge-margin-horizontal = 10;
        notification-margin = 10;

        background = "2e3440ff";
        border-color = "81a1c1ff";
        border-radius = 8;
        border-size = 3;

        title-font = "monospace:size=12";
        summary-font = "monospace:size=12";
        body-font = "monospace:size=12";

        title-color = "e5e9f0ff";
        summary-color = "e5e9f0ff";
        body-color = "e5e9f0ff";

        progress-color = "88c0d0ff";
        progress-style = "bar";
      };
    };
  };
}
