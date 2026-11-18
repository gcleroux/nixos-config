{ pkgs, ... }:
{
  programs.mpv = {
    enable = true;

    bindings = {
      "BS" = "cycle pause";
      "SPACE" = "cycle pause";

      "\\" = "set speed 1.0";
      "+" = "add speed 0.05";
      "-" = "add speed -0.05";

      "UP" = "add chapter -1";
      "DOWN" = "add chapter 1";

      "RIGHT" = "add video-rotate 90";
      "LEFT" = "add video-rotate -90";

      "h" = "seek -5";
      "j" = "add volume -2";
      "k" = "add volume 2";
      "l" = "seek 5";

      "Shift+H" = "seek -60";
      "Shift+L" = "seek +60";

      "O" = "cycle osc; cycle osd-bar";
    };

    config = {
      profile = "gpu-hq";
      hwdec = "vaapi,auto-safe";
      gpu-context = "wayland";
      force-window = true;
      keep-open = "no";
      osc = "no";
      osd-bar = "no";
      ytdl-format = "bestvideo+bestaudio";
    };
  };
}
