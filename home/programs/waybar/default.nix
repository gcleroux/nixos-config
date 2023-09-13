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

        modules-left = [ "hyprland/workspaces" "custom/right-arrow-dark" ];
        modules-center = [
          "custom/left-arrow-dark"
          "clock#1"
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
          "clock#2"
          "custom/right-arrow-dark"
          "custom/right-arrow-light"
          "clock#3"
          "custom/right-arrow-dark"
        ];
        modules-right = [
          "custom/left-arrow-dark"
          "pulseaudio"
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
          "memory"
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
          "cpu"
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
          "battery"
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
          "disk"
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
          "tray"
        ];

        "custom/left-arrow-dark" = {
          format = "";
          tooltip = false;
        };
        "custom/left-arrow-light" = {
          format = "";
          tooltip = false;
        };
        "custom/right-arrow-dark" = {
          format = "";
          tooltip = false;
        };
        "custom/right-arrow-light" = {
          format = "";
          tooltip = false;
        };

        "hyprland/workspaces" = {
          active-only = false;
          format = "{id}";
        };

        "clock#1" = {
          format = "{:%a}";
          tooltip = false;
        };
        "clock#2" = {
          format = "{:%H:%M}";
          tooltip = false;
        };
        "clock#3" = {
          format = "{:%m-%d}";
          tooltip = false;
        };
        "pulseaudio" = {
          format = "{icon} {volume:3}%";
          format-bluetooth = "{icon}  {volume}%";
          format-muted = "󰝟 MUTE";
          format-icons = {
            headphones = "";
            default = [ "" "" ];
          };
          on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
        };
        "memory" = {
          interval = 5;
          format = "RAM {}%";
        };
        "cpu" = {
          interval = 5;
          format = "CPU {usage:2}%";
        };
        "battery" = {
          interval = 5;
          states = {
            "good" = 95;
            "warning" = 25;
            "critical" = 15;
          };
          format = "{icon}  {capacity}%";
          format-charging = " {capacity}%";
          format-icons = [ "" "" "" "" "" ];
        };
        "disk" = {
          interval = 5;
          format = "Disk {percentage_used:2}%";
          path = "/";
        };
        "tray" = {
          icon-size = 20;
          spacing = 5;
        };
      };
    };
    style = ./style.css;
  };
}
