let
  configDir = "hypr/config.d/";
  scriptsDir = "hypr/scripts/";
in {
  # TODO: Find a cleaner way to manage config
  xdg.configFile = {
    # Config files
    "${configDir}autostart.conf".source = ./config.d/autostart.conf;
    "${configDir}env.conf".source = ./config.d/env.conf;
    "${configDir}input.conf".source = ./config.d/input.conf;
    "${configDir}keybinds.conf".source = ./config.d/keybinds.conf;
    "${configDir}monitors.conf".source = ./config.d/monitors.conf;
    "${configDir}window-rules.conf".source = ./config.d/window-rules.conf;

    # Scripts files
    "${scriptsDir}airplane-mode".source = ./scripts/airplane-mode;
    "${scriptsDir}brightness".source = ./scripts/brightness;
    "${scriptsDir}keyboard-layout".source = ./scripts/keyboard-layout;
    "${scriptsDir}volume".source = ./scripts/volume;
    "${scriptsDir}swww_random".source = ./scripts/swww_random;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    xwayland.enable = true;

    extraConfig = ''
      # Sourcing config files
      source=$HOME/.config/hypr/config.d/autostart.conf
      source=$HOME/.config/hypr/config.d/env.conf
      # TODO: Once I switch to kanshi, I should not preset monitor settings
      source=$HOME/.config/hypr/config.d/monitors.conf
      source=$HOME/.config/hypr/config.d/input.conf
      source=$HOME/.config/hypr/config.d/keybinds.conf
      source=$HOME/.config/hypr/config.d/window-rules.conf

      general {
          gaps_in = 5
          gaps_out = 10
          border_size = 2
          col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
          col.inactive_border = rgba(595959aa)

          layout = master
      }

      decoration {
          rounding = 10

          blur {
            enabled = false
            size = 3
            passes = 1
            new_optimizations = true
          }

          drop_shadow = yes
          shadow_range = 4
          shadow_render_power = 3
          col.shadow = rgba(1a1a1aee)
      }

      animations {
          enabled = yes
          bezier = myBezier, 0.05, 0.9, 0.1, 1.05
          animation = windows, 1, 7, myBezier
          animation = windowsOut, 1, 7, default, popin 80%
          animation = border, 1, 10, default
          animation = borderangle, 1, 8, default
          animation = fade, 1, 7, default
          animation = workspaces, 1, 6, default
      }

      dwindle {
          pseudotile = yes
          preserve_split = yes
      }

      master {
          new_is_master = false   # New windows join as slaves
      }

      gestures {
          workspace_swipe = on
          workspace_swipe_fingers = 4
      }

      misc {
          disable_hyprland_logo = yes
          disable_splash_rendering = yes
      }
    '';
  };
}
