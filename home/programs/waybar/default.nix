{ pkgs, ... }: {

  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = "hyprland-session.target";
    };

    settings = {
      mainBar = {
        layer = "top";
        position = "top";

        modules-left = [
          # "custom/launcher"
          "hyprland/workspaces"
          "temperature"
          "pulseaudio"
          "idle_inhibitor"
          "mpd"
          # "custom/cava-internal"
        ];

        modules-center = [ "custom/weather" "clock" ];

        modules-right = [
          "backlight"
          "disk"
          "memory"
          "cpu"
          "battery"
          "hyprland/language"
          "tray"
          # "custom/powermenu"
        ];

        "hyprland/workspaces" = {
          active-only = false;
          all-outputs = true;
          format = "{icon}";
          format-icons = {
            "1" = "一";
            "2" = "二";
            "3" = "三";
            "4" = "四";
            "5" = "五";
            "6" = "六";
            "7" = "七";
            "8" = "八";
            "9" = "九";
            "10" = "十";
            "urgent" = "";
            "focused" = "";
            "default" = "";
          };
        };

        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "󰈈";
            deactivated = "󰈉";
          };
          tooltip = false;
        };

        pulseaudio = {
          format = "{icon} {volume:3}%";
          format-bluetooth = " {volume}%";
          format-muted = "󰝟 Muted";
          format-icons = {
            headphones = "";
            default = [ "" "" "" ];
          };
          on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
          tooltip = false;
        };

        mpd = {
          max-length = 25;
          format = "<span foreground='#bb9af7'></span> {title}";
          format-paused = " {title}";
          format-stopped = "<span foreground='#bb9af7'></span>";
          format-disconnected = "";
          on-click = "${pkgs.mpc-cli}/bin/mpc --quiet toggle";
          on-click-right =
            "${pkgs.alacritty}/bin/alacritty --command ${pkgs.ncmpcpp}/bin/ncmpcpp";
          on-scroll-up = "${pkgs.mpc-cli}/bin/mpc --quiet prev";
          on-scroll-down = "${pkgs.mpc-cli}/bin/mpc --quiet next";
          smooth-scrolling-threshold = 5;
          tooltip-format =
            "{title} - {artist} ({elapsedTime:%M:%S}/{totalTime:%H:%M:%S})";
        };
        temperature = {
          hwmon-path = "/sys/class/hwmon/hwmon4/temp2_input";
          critical-threshold = 80;
          tooltip = false;
          format = " {temperatureC}°C";
        };
        clock = {
          on-click =
            "${pkgs.libsForQt5.merkuro}/bin/merkuro-calendar --platform wayland";
          interval = 1;
          format = "{:%I:%M %p  %A %b %d}";
          tooltip = true;
          tooltip-format = "{:%A, %d %B %Y} <tt>{calendar}</tt>";
        };
        backlight = {
          device = "intel_backlight";
          format = "{icon} {percent}%";
          format-icons = [ "󱩏" "󱩑" "󱩓" "󱩕" "󰛨" ];
        };
        memory = {
          on-click =
            "${pkgs.alacritty}/bin/alacritty --command ${pkgs.bottom}/bin/btm";
          interval = 5;
          format = " {percentage:2}%";
          states = { "warning" = 90; };
        };
        cpu = {
          interval = 5;
          format = " {usage:2}%";
        };
        battery = {
          interval = 10;
          states = {
            "good" = 95;
            "warning" = 25;
            "critical" = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󱊦 {capacity}%";
          format-icons = [ "󰂎" "󱊡" "󱊢" "󱊣" ];
          tooltip = true;
        };
        disk = {
          interval = 30;
          format = " {used}";
          path = "/";
          tooltip = true;
          tooltip-format = "{used}/{total} => {path} {percentage_used}%";
        };
        tray = {
          icon-size = 20;
          spacing = 5;
        };
        "hyprland/language" = { format = "󰌌 {short}"; };
      };
    };
    style = ./style.css;
  };
}

# "custom/launcher": {
#   "format": "",
#   "on-click": "wofi --show drun -I -a",
#   "tooltip-format": "sudo pacman -Q linux",
#   "tooltip": false,
# },
# "custom/powermenu": {
#   "format": "",
#   "on-click": "~/.config/rofi/powermenu.sh",
#   "tooltip": false
# },
