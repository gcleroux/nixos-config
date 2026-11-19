{ pkgs, ... }:
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";

        modules-left = [
          "river/tags"
          "temperature"
          "pulseaudio"
          "idle_inhibitor"
        ];

        modules-center = [ "clock" ];

        modules-right = [
          "backlight"
          "disk"
          "memory"
          "cpu"
          "battery"
          "tray"
        ];

        "river/tags" = {
          num-tags = 5;
          tag-labels = [
            "𝍠"
            "𝍡"
            "𝍢"
            "𝍣"
            "𝍤"
          ];
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
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
          tooltip = false;
        };

        temperature = {
          hwmon-path-abs = "/sys/devices/platform/coretemp.0/hwmon";
          input-filename = "temp1_input";
          critical-threshold = 80;
          tooltip = false;
          format = " {temperatureC}°C";
        };
        clock = {
          format = "{:%I:%M %p | %A, %b %d}";
          tooltip = true;
          tooltip-format = "{:%A, %d %B %Y} <tt>{calendar}</tt>";
        };
        backlight = {
          device = "intel_backlight";
          format = "{icon} {percent}%";
          format-icons = [
            "󱩏"
            "󱩑"
            "󱩓"
            "󱩕"
            "󰛨"
          ];
        };
        memory = {
          on-click = "${pkgs.foot}/bin/foot ${pkgs.bottom}/bin/btm";
          interval = 5;
          format = " {percentage:2}%";
          states = {
            "warning" = 90;
          };
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
          format-icons = [
            "󰂎"
            "󱊡"
            "󱊢"
            "󱊣"
          ];
          tooltip = true;
        };
        disk = {
          interval = 1800;
          format = " {used}";
          tooltip = true;
          tooltip-format = "{used}/{total} => {path} {percentage_used}%";
        };
        tray = {
          icon-size = 20;
          spacing = 5;
        };
      };
    };
    style = ./style.css;
  };
}
