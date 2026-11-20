{
  pkgs,
  config,
  ...
}:
let
  # A script from ./scripts, run with the tools it needs on its PATH
  script =
    name: runtimeInputs:
    pkgs.writeShellApplication {
      inherit name runtimeInputs;
      text = builtins.readFile ./scripts/${name}.sh;
    };

  # Media keys
  volume = script "volume" [
    pkgs.gawk
    pkgs.libnotify
    pkgs.wireplumber
  ];
  brightness = script "brightness" [
    pkgs.brightnessctl
    pkgs.libnotify
  ];

  # fzf menus, opened in a floating terminal
  appMenu = script "_applauncher" [
    pkgs.dex
    pkgs.fd
    pkgs.fzf
  ];
  clipboardMenu = script "_cliphist" [
    pkgs.cliphist
    pkgs.fzf
    pkgs.wl-clipboard
  ];
  emojiMenu = script "_emoji" [
    pkgs.fzf
    pkgs.wl-clipboard
  ];
  notificationMenu = script "_notifications" [
    config.services.dunst.package
    pkgs.chafa
    pkgs.fzf
    pkgs.jq
  ];
  kanshictl = "${config.services.kanshi.package}/bin/kanshictl";

  launcher = script "launcher" [
    pkgs.fzf
    appMenu
    clipboardMenu
    emojiMenu
    notificationMenu
  ];

  # Notifications
  dunstctl = "${config.services.dunst.package}/bin/dunstctl";
  notificationRemove = script "notification-remove" [
    config.services.dunst.package
    pkgs.jq
  ];
in
{
  home.packages = with pkgs; [
    lswt
    wlr-randr
  ];

  wayland.windowManager.river = {
    enable = true;
    # uwsm (hosts/howl) starts and stops graphical-session.target with river
    systemd.enable = false;
    # river and Xwayland come from the host (programs.river-classic)
    package = null;
    xwayland.enable = false;
    extraConfig = ''
      # Programs keybinds
      # =================
      riverctl map normal Super Return spawn ${config.home.sessionVariables.TERMINAL}
      riverctl map normal Super B spawn ${config.home.sessionVariables.BROWSER}
      riverctl map normal Super D spawn vesktop
      riverctl map normal Super F spawn thunar
      riverctl map normal Control+Alt L spawn swaylock
      riverctl map normal Super V spawn "${config.home.sessionVariables.TERMINAL} --title fzf-launcher ${clipboardMenu}/bin/_cliphist"
      riverctl map normal Control Space spawn "${config.home.sessionVariables.TERMINAL} --title fzf-launcher ${appMenu}/bin/_applauncher"
      riverctl map normal Control Semicolon spawn "${config.home.sessionVariables.TERMINAL} --title fzf-launcher ${emojiMenu}/bin/_emoji"
      riverctl map normal Control+Shift Space spawn "${config.home.sessionVariables.TERMINAL} --title fzf-launcher ${launcher}/bin/launcher"

      # Notifications
      # =============
      # Hidden notifications stay in the list on Super+N; Super+Control+Grave removes one for good
      riverctl map normal Super Grave spawn "${dunstctl} close"
      riverctl map normal Super+Shift Grave spawn "${dunstctl} close-all"
      riverctl map normal Super+Control Grave spawn "${notificationRemove}/bin/notification-remove"
      riverctl map normal Super N spawn "${config.home.sessionVariables.TERMINAL} --title fzf-launcher ${notificationMenu}/bin/_notifications"

      # Screenshot
      riverctl map -release normal None Print spawn '${pkgs.grim}/bin/grim -l 0 -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy'
      riverctl map -release normal Shift Print spawn '${pkgs.slurp}/bin/slurp | ${pkgs.grim}/bin/grim -g - ~/Pictures/Screenshots/$(date +"screenshot_%Y-%m-%d-%H%M%S.png")'

      # Super+Q to close the focused view
      riverctl map normal Super Q close

      # Super+J and Super+K to focus the next/previous view in the layout stack
      riverctl map normal Super J focus-view next
      riverctl map normal Super K focus-view previous

      # Super+Shift+J and Super+Shift+K to swap the focused view with the next/previous
      # view in the layout stack
      riverctl map normal Super+Shift J swap next
      riverctl map normal Super+Shift K swap previous

      # Move focus to different output
      riverctl map normal Super H focus-output left
      riverctl map normal Super L focus-output right

      # Move window to different output (keeps focus on window)
      riverctl map normal Super+Shift H spawn 'riverctl send-to-output left && riverctl focus-output left'
      riverctl map normal Super+Shift L spawn 'riverctl send-to-output right && riverctl focus-output right'

      # Super+Shift+Return to bump the focused view to the top of the layout stack
      riverctl map normal Super+Shift Return zoom

      # Super+Alt+J and Super+Alt+K to decrease/increase the main ratio of rivertile(1)
      riverctl map normal Super+Alt J send-layout-cmd rivertile "main-ratio -0.05"
      riverctl map normal Super+Alt K send-layout-cmd rivertile "main-ratio +0.05"

      # Super+Alt+H and Super+Alt+L to increment/decrement the main count of rivertile(1)
      riverctl map normal Super+Alt H send-layout-cmd rivertile "main-count +1"
      riverctl map normal Super+Alt L send-layout-cmd rivertile "main-count -1"

      # Alt+Shift+{H,J,K,L} to snap views to screen edges
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

      	# Super+[1-5] to focus tag [1-5]
      	riverctl map normal Super $i set-focused-tags $tags

      	# Super+Shift+[1-5] to move the focused view to tag [1-5]
      	riverctl map normal Super+Shift $i set-view-tags $tags

      	# Super+Control+[1-5] to toggle focus of tag [1-5]
      	riverctl map normal Super+Control $i toggle-focused-tags $tags

      	# Super+Shift+Control+[1-5] to toggle tag [1-5] of the focused view
      	riverctl map normal Super+Shift+Control $i toggle-view-tags $tags
      done

      # Focus views under all tags
      all_tags=$(((1 << 32) - 1))
      riverctl map normal Super 0 set-focused-tags $all_tags

      # View window under all tags
      riverctl map normal Super+Shift 0 set-view-tags $all_tags

      # Toggle float
      riverctl map normal Super Space toggle-float

      # Toggle fullscreen
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

      # Media keys, also on the lock screen
      for mode in normal locked; do
      	# Output volume
      	riverctl map -repeat $mode None XF86AudioRaiseVolume spawn "${volume}/bin/volume --inc-output"
      	riverctl map -repeat $mode None XF86AudioLowerVolume spawn "${volume}/bin/volume --dec-output"
      	riverctl map $mode None XF86AudioMute spawn "${volume}/bin/volume --toggle-output"

      	# Input volume control
      	riverctl map -repeat $mode Shift XF86AudioRaiseVolume spawn "${volume}/bin/volume --inc-input"
      	riverctl map -repeat $mode Shift XF86AudioLowerVolume spawn "${volume}/bin/volume --dec-input"
      	riverctl map $mode Shift XF86AudioMute spawn "${volume}/bin/volume --toggle-input"

      	# Control MPRIS aware media players with playerctl (https://github.com/altdesktop/playerctl)
      	riverctl map $mode None XF86AudioMedia spawn 'playerctl play-pause'
      	riverctl map $mode None XF86AudioPlay spawn 'playerctl play-pause'
      	riverctl map $mode None XF86AudioPrev spawn 'playerctl previous'
      	riverctl map $mode None XF86AudioNext spawn 'playerctl next'

      	# Control screen backlight brightness with brightnessctl (https://github.com/Hummer12007/brightnessctl)
      	riverctl map -repeat $mode None XF86MonBrightnessUp spawn "${brightness}/bin/brightness --inc"
      	riverctl map -repeat $mode None XF86MonBrightnessDown spawn "${brightness}/bin/brightness --dec"

        # Lid closed while docked: turn off eDP-1. Undocked, the switch doesn't match and logind suspends.
        # Opening it lets kanshi pick the profile for the connected outputs again.
        riverctl map-switch $mode lid close spawn "${kanshictl} switch docked-lid-closed"
        riverctl map-switch $mode lid open spawn "${kanshictl} reload"
      done

      # Borders
      riverctl border-width 3
      riverctl border-color-focused 0x81a1c1
      riverctl border-color-unfocused 0x595959

      # Make fzf-launcher floating with set dimensions
      riverctl rule-add -title 'fzf-launcher' float
      riverctl rule-add -title 'fzf-launcher' dimensions 1000 200

      riverctl rule-add -app-id 'float*' float
      riverctl rule-add -app-id 'nm-connection-editor' float
      riverctl rule-add -app-id '.blueman-manager-wrapped' float
      riverctl rule-add -app-id 'imv' float
      riverctl rule-add -app-id 'mpv' float
      riverctl rule-add -app-id 'pavucontrol' float
      riverctl rule-add -app-id 'thunar' -title 'File Operation Progress' float

      # Make firefox use server-side decorations
      riverctl rule-add -app-id firefox ssd

      # Set keyboard repeat rate
      riverctl set-repeat 50 300

      # Set keyboard layout
      riverctl keyboard-layout -variant ",,multix" -options "shift:both_capslock,caps:escape,grp:alt_space_toggle" eu,us,ca

      # Touchpads, including ones connected later
      riverctl input '*Touchpad' tap enabled
      riverctl input '*Touchpad' tap-button-map left-right-middle
      riverctl input '*Touchpad' scroll-method two-finger
      riverctl input '*Touchpad' natural-scroll enabled
      riverctl input '*Touchpad' scroll-factor 0.15

      # Cursor config
      riverctl focus-follows-cursor normal
      riverctl hide-cursor timeout 10000
      riverctl set-cursor-warp on-focus-change

      # Set the default layout generator to be rivertile and start it.
      # River will send the process group of the init executable SIGTERM on exit.
      riverctl default-layout rivertile
      rivertile -view-padding 6 -outer-padding 6 -main-ratio 0.5 &

      # Tells uwsm river is ready: exports WAYLAND_DISPLAY to systemd and starts graphical-session.target
      ${pkgs.uwsm}/bin/uwsm finalize
    '';
  };

  # https://codeberg.org/river/wiki#workaround-for-firefox
  dconf.settings."org/gnome/desktop/wm/preferences" = {
    button-layout = "";
  };
}
