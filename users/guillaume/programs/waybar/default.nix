{ pkgs, ... }:
{

  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      targets = [ "river-session.target" ];
    };

    settings = {
      mainBar = {
        layer = "top";
        position = "top";

        modules-left = [
          # "custom/launcher"
          "river/tags"
          "temperature"
          "pulseaudio"
          "idle_inhibitor"
          # "river/mode"
          # "river/window"

          # "custom/cava-internal"
        ];

        modules-center = [
          "custom/weather"
          "clock"
        ];

        modules-right = [
          "custom/brightness"
          "disk"
          "memory"
          "cpu"
          "battery"
          # "hyprland/language"
          "tray"
          # "custom/powermenu"
        ];
        "river/mode" = {
          format = "mode: {}";
        };
        "river/window" = {
          format = "mode: {}";
        };

        "river/tags" = {
          num-tags = 5;
          tag-labels = [
            "𝍠"
            "𝍡"
            "𝍢"
            "𝍣"
            "𝍤"
            "𝍥"
            "𝍦"
            "𝍧"
          ];
          # "urgent" = "";
          # "focused" = "";
          # "default" = "";
          # };
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
          on-click = "${pkgs.kdePackages.merkuro}/bin/merkuro-calendar --platform wayland";
          interval = 1;
          format = "{:%I:%M %p | %A, %b %d}";
          tooltip = true;
          tooltip-format = "{:%A, %d %B %Y} <tt>{calendar}</tt>";
        };
        "custom/brightness" = {
          interval = 5;
          format = "{icon} {}%";
          format-icons = [
            "󱩏"
            "󱩑"
            "󱩓"
            "󱩕"
            "󰛨"
          ];
          exec = pkgs.writeShellScript "brightness" ''
            # Get the brightness percentage of the display as an int
            ${pkgs.brightnessctl}/bin/brightnessctl -m | \
            ${pkgs.busybox}/bin/cut -d, -f4 | \
            ${pkgs.busybox}/bin/tr -d '%' | \
            ${pkgs.jq}/bin/jq -cR --unbuffered '{"text": ., "percentage": tonumber}'
          '';
          return-type = "json";
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
          path = "/";
          tooltip = true;
          tooltip-format = "{used}/{total} => {path} {percentage_used}%";
        };
        tray = {
          icon-size = 20;
          spacing = 5;
        };
        "hyprland/language" = {
          format = "󰌌 {short}";
        };
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
