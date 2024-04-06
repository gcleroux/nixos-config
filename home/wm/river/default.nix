{ pkgs, ... }: {
  wayland.windowManager.river = {
    enable = true;
    systemd.enable = true;
    xwayland.enable = true;
    extraSessionVariables = { XCURSOR_SIZE = 24; };
    extraConfig = ''
      #!/usr/bin/env sh

      scripts=$HOME/.config/river/scripts

      # This is the example configuration file for river.
      #
      # If you wish to edit this, you will probably want to copy it to
      # $XDG_CONFIG_HOME/river/init or $HOME/.config/river/init first.
      #
      # See the river(1), riverctl(1), and rivertile(1) man pages for complete
      # documentation.

      # Autostart programs
      # ==================
      # riverctl spawn "swww init; sleep 2 && ${pkgs.custom-scripts}/bin/swww_random ~/Pictures/Wallpapers"
      riverctl spawn "way-displays > /tmp/way-displays.$XDG_VTNR.$USER.log 2>&1"
      riverctl spawn "wbg ~/Pictures/Wallpapers/murky_peaks.jpg"
      riverctl spawn "nm-applet --indicator"
      riverctl spawn "spotify_player -d"
      riverctl spawn "signal-desktop --start-in-tray"

      # Using swayidle here since ddcutil breaks with a home-manager service
      riverctl spawn '${pkgs.swayidle}/bin/swayidle -w \
                     timeout 240 "${pkgs.libnotify}/bin/notify-send -h string:x-canonical-private-synchronous:sys-notify -u low -c overlay Locking system in 1 minute" \
                     timeout 300 "${pkgs.swaylock}/bin/swaylock" \
                     timeout 600 "${pkgs.custom-scripts}/bin/brightness --dpms-off" \
                          resume "${pkgs.custom-scripts}/bin/brightness --dpms-on" \
                     before-sleep "${pkgs.swaylock}/bin/swaylock"'

      riverctl map normal Super Return spawn foot
      riverctl map normal Control Space spawn "wofi --allow-images --show drun"
      riverctl map normal Control Semicolon spawn ${pkgs.custom-scripts}/bin/emoji # CTRL+;
      riverctl map normal Super B spawn chromium-browser
      riverctl map normal Super D spawn vesktop
      riverctl map normal Super F spawn thunar
      riverctl map normal Control+Alt L spawn swaylock
      riverctl map normal Super V spawn "cliphist list | wofi --dmenu | cliphist decode | wl-copy"

      riverctl map -release normal None Print spawn 'grim -l 0 -g "$(slurp)" - | wl-copy'
      riverctl map -release normal Shift Print spawn "slurp | grim -g - ~/Pictures/Screenshots/$(date +'screenshot_%Y-%m-%d-%H%M%S.png')"

      # Super+Q to close the focused view
      riverctl map normal Super Q close

      # Super+Shift+E to exit river
      riverctl map normal Super+Shift E exit

      # Super+J and Super+K to focus the next/previous view in the layout stack
      riverctl map normal Super J focus-view next
      riverctl map normal Super K focus-view previous

      # Super+Shift+J and Super+Shift+K to swap the focused view with the next/previous
      # view in the layout stack
      riverctl map normal Super+Shift J swap next
      riverctl map normal Super+Shift K swap previous

      # Super+Period and Super+Comma to focus the next/previous output
      riverctl map normal Super H focus-output next
      riverctl map normal Super L focus-output previous

      # Super+Shift+{Period,Comma} to send the focused view to the next/previous output
      riverctl map normal Super+Shift H send-to-output next
      riverctl map normal Super+Shift L send-to-output previous

      # Super+Return to bump the focused view to the top of the layout stack
      riverctl map normal Super+Shift Return zoom

      # Super+H and Super+L to decrease/increase the main ratio of rivertile(1)
      riverctl map normal Super+Alt J send-layout-cmd rivertile "main-ratio -0.05"
      riverctl map normal Super+Alt K send-layout-cmd rivertile "main-ratio +0.05"

      # Super+Shift+H and Super+Shift+L to increment/decrement the main count of rivertile(1)
      riverctl map normal Super+Alt H send-layout-cmd rivertile "main-count +1"
      riverctl map normal Super+Alt L send-layout-cmd rivertile "main-count -1"

      # Super+Alt+{H,J,K,L} to move views
      # riverctl map normal Alt H move left 100
      # riverctl map normal Alt J move down 100
      # riverctl map normal Alt K move up 100
      # riverctl map normal Alt L move right 100

      # Super+Alt+Control+{H,J,K,L} to snap views to screen edges
      riverctl map normal Alt+Shift H snap left
      riverctl map normal Alt+Shift J snap down
      riverctl map normal Alt+Shift K snap up
      riverctl map normal Alt+Shift L snap right

      # Super+Alt+Shift+{H,J,K,L} to resize views
      riverctl map normal Super+Alt+Shift H resize horizontal -100
      riverctl map normal Super+Alt+Shift J resize vertical 100
      riverctl map normal Super+Alt+Shift K resize vertical -100
      riverctl map normal Super+Alt+Shift L resize horizontal 100

      # Super + Left Mouse Button to move views
      riverctl map-pointer normal Super BTN_LEFT move-view

      # Super + Right Mouse Button to resize views
      riverctl map-pointer normal Super BTN_RIGHT resize-view

      # Super + Middle Mouse Button to toggle float
      riverctl map-pointer normal Super BTN_MIDDLE toggle-float

      for i in $(seq 1 5); do
      	tags=$((1 << ($i - 1)))

      	# Super+[1-9] to focus tag [0-8]
      	riverctl map normal Super $i set-focused-tags $tags

      	# Super+Shift+[1-9] to tag focused view with tag [0-8]
      	riverctl map normal Super+Shift $i set-view-tags $tags

      	# Super+Control+[1-9] to toggle focus of tag [0-8]
      	riverctl map normal Super+Control $i toggle-focused-tags $tags

      	# Super+Shift+Control+[1-9] to toggle tag [0-8] of focused view
      	riverctl map normal Super+Shift+Control $i toggle-view-tags $tags
      done

      # Super+0 to focus all tags
      # Super+Shift+0 to tag focused view with all tags
      all_tags=$(((1 << 32) - 1))
      riverctl map normal Super 0 set-focused-tags $all_tags
      riverctl map normal Super+Shift 0 set-view-tags $all_tags

      # Super+Space to toggle float
      riverctl map normal Super Space toggle-float

      # Super+F to toggle fullscreen
      riverctl map normal Super+Shift Space toggle-fullscreen

      # Super+{Up,Right,Down,Left} to change layout orientation
      riverctl map normal Super Up send-layout-cmd rivertile "main-location top"
      riverctl map normal Super Right send-layout-cmd rivertile "main-location right"
      riverctl map normal Super Down send-layout-cmd rivertile "main-location bottom"
      riverctl map normal Super Left send-layout-cmd rivertile "main-location left"

      # Declare a passthrough mode. This mode has only a single mapping to return to
      # normal mode. This makes it useful for testing a nested wayland compositor
      riverctl declare-mode passthrough

      # Super+F11 to enter passthrough mode
      riverctl map normal Super F11 enter-mode passthrough

      # Super+F11 to return to normal mode
      riverctl map passthrough Super F11 enter-mode normal

      # Various media key mapping examples for both normal and locked mode which do
      # not have a modifier
      for mode in normal locked; do
      	# Control pulse audio volume with pamixer (https://github.com/cdemoulins/pamixer)
      	riverctl map -repeat $mode None XF86AudioRaiseVolume spawn "${pkgs.custom-scripts}/bin/volume --inc-output"
      	riverctl map -repeat $mode None XF86AudioLowerVolume spawn "${pkgs.custom-scripts}/bin/volume --dec-output"
      	riverctl map $mode None XF86AudioMute spawn "${pkgs.custom-scripts}/bin/volume --toggle-output"

      	# Input volume control
      	riverctl map -repeat $mode Shift XF86AudioRaiseVolume spawn "${pkgs.custom-scripts}/bin/volume --inc-input"
      	riverctl map -repeat $mode Shift XF86AudioLowerVolume spawn "${pkgs.custom-scripts}/bin/volume --dec-input"
      	riverctl map $mode Shift XF86AudioMute spawn "${pkgs.custom-scripts}/bin/volume --toggle-input"

      	# Control MPRIS aware media players with playerctl (https://github.com/altdesktop/playerctl)
      	riverctl map $mode None XF86AudioMedia spawn 'playerctl play-pause'
      	riverctl map $mode None XF86AudioPlay spawn 'playerctl play-pause'
      	riverctl map $mode None XF86AudioPrev spawn 'playerctl previous'
      	riverctl map $mode None XF86AudioNext spawn 'playerctl next'

      	# Control screen backlight brightness with brightnessctl (https://github.com/Hummer12007/brightnessctl)
      	riverctl map -repeat $mode None XF86MonBrightnessUp spawn "${pkgs.custom-scripts}/bin/brightness --inc"
      	riverctl map -repeat $mode None XF86MonBrightnessDown spawn "${pkgs.custom-scripts}/bin/brightness --dec"
      done

      # Set background and border color
      riverctl border-width 3
      # riverctl background-color 0x000000
      riverctl border-color-focused 0x81a1c1
      riverctl border-color-unfocused 0x595959

      # Set keyboard repeat rate
      # riverctl set-repeat 50 300

      # Make all views with an app-id that starts with "float" and title "foo" start floating.
      riverctl rule-add -app-id 'float*' float

      riverctl rule-add -title 'wofi' float
      riverctl rule-add -title 'nm-connection-editor' float
      riverctl rule-add -title 'blueman-manager' float
      riverctl rule-add -title 'imv' float
      riverctl rule-add -title 'mpv' float
      riverctl rule-add -title 'pavucontrol' float

      # Make all views with app-id "bar" and any title use client-side decorations
      riverctl rule-add -app-id "bar" csd

      # Set keyboard repeat rate
      riverctl set-repeat 50 300

      # Set keyboard layout
      riverctl keyboard-layout -variant ",,multix" -options "shift:both_capslock,caps:escape,grp:alt_space_toggle" eu,us,ca

      # Set touchpad by grabbing the event
      for pad in $(riverctl list-inputs | grep -i touchpad); do
      	riverctl input $pad events enabled
      	riverctl input $pad tap enabled
      	riverctl input $pad tap-button-map left-right-middle
      	riverctl input $pad scroll-method two-finger
      	riverctl input $pad natural-scroll enabled
      done

      # Cursor config
      riverctl focus-follows-cursor normal
      riverctl hide-cursor timeout 10000

      # Set the default layout generator to be rivertile and start it.
      # River will send the process group of the init executable SIGTERM on exit.
      riverctl default-layout rivertile
      rivertile -view-padding 6 -outer-padding 6 &
    '';
  };
}
