{
  config,
  lib,
  pkgs,
  ...
}:
let
  swaymsg = "${config.programs.sway.package}/bin/swaymsg";

  # Sunshine outlives Sway sessions, and greetd leaves dead sessions' sockets behind
  findSway = ''
    SWAYSOCK=$(ls -t "$XDG_RUNTIME_DIR"/sway-ipc.*.sock | head -n 1)
    export SWAYSOCK
  '';

  # Between streams; each stream sets the mode its client asked for (setMode)
  idle = {
    width = "1920";
    height = "1080";
    refresh = "119.879";
  };

  # A kiosk on the HDMI dummy plug: whichever window has the focus fills the screen
  swayConfig = pkgs.writeText "sway-games.conf" ''
    # Starts graphical-session.target, which Sunshine waits for
    include /etc/sway/config.d/*

    output HDMI-A-1 mode ${idle.width}x${idle.height}@${idle.refresh}Hz
    default_border none

    # A window that asks for the focus gets it, e.g. a game resumed from Big Picture, but only
    # while its workspace is shown: between streams, Steam would bring its windows back on screen
    focus_on_window_activation smart
    for_window [all] fullscreen enable

    # Every window lives on workspace 1, so the empty "idle" workspace hides them all: hidden
    # windows aren't asked for frames, and the GPU idles between streams (streamEnd)
    assign [class=".*"] workspace number 1
    assign [app_id=".*"] workspace number 1
    exec ${fullscreenFocused}

    exec steam -gamepadui
    exec ${idleOnceDrawn}
  '';

  # Big Picture only draws once it has been on screen; a stream starting before that is black
  idleOnceDrawn = pkgs.writeShellScript "kiosk-idle-once-drawn" ''
    until ${swaymsg} '[class="steam" title="Steam Big Picture Mode"] focus' >/dev/null 2>&1; do sleep 1; done
    sleep 5
    exec ${swaymsg} workspace idle
  '';

  # Only one window can be fullscreen, and Sway doesn't hand it back when that window
  # closes or loses the focus: the others would tile side by side. Give it to the focused one.
  fullscreenFocused = pkgs.writeShellScript "kiosk-fullscreen-focused" ''
    ${swaymsg} -t subscribe -m -r '["window"]' |
      ${pkgs.gnugrep}/bin/grep --line-buffered -E '^\{ "change": "(focus|close)"' |
      while read -r _; do ${swaymsg} fullscreen enable >/dev/null; done
  '';

  # A Moonlight tile: brings the first open window matching the criteria to the front, or
  # starts the app if none is open
  showOrStart =
    name: criteria: start:
    pkgs.writeShellScript "show-${name}" ''
      ${findSway}
      for c in ${lib.escapeShellArgs criteria}; do
        ${swaymsg} "$c focus" >/dev/null 2>&1 && exit 0
      done
      exec ${pkgs.util-linux}/bin/setsid ${start}
    '';

  # Let the moonlight client set the screen resolution for sunshine streaming.
  # Sway picks the closest resolution available
  setMode = pkgs.writeShellScript "kiosk-set-mode" ''
    ${findSway}
    width=''${1:-$SUNSHINE_CLIENT_WIDTH} height=''${2:-$SUNSHINE_CLIENT_HEIGHT} fps=''${3:-$SUNSHINE_CLIENT_FPS}
    if ${swaymsg} -t get_outputs -r |
      ${pkgs.jq}/bin/jq -e --argjson w "$width" --argjson h "$height" \
        '.[] | select(.name == "HDMI-A-1") | .modes | any(.width == $w and .height == $h)' >/dev/null; then
      ${swaymsg} output HDMI-A-1 mode "''${width}x''${height}@''${fps}Hz" >/dev/null
    fi
    exit 0
  '';

  # The GPU doesn't render anything between streams to save power
  streamStart = pkgs.writeShellScript "kiosk-stream-start" ''
    ${findSway}
    ${swaymsg} workspace number 1 >/dev/null
    exec ${setMode}
  '';
  streamEnd = pkgs.writeShellScript "kiosk-stream-end" ''
    ${setMode} ${idle.width} ${idle.height} ${idle.refresh}
    ${findSway}
    ${swaymsg} workspace idle >/dev/null
    exit 0
  '';

  prism = pkgs.prismlauncher;
in
{
  # Owns the session, Steam and its games. No password: the autologin is its only way in.
  users.users.games = {
    isNormalUser = true;
    # Sunshine's virtual keyboard, mouse and gamepads
    extraGroups = [
      "input"
      "uinput"
    ];
    packages = [ prism ];
  };

  services.greetd =
    let
      kiosk = {
        user = "games";
        command = "${config.programs.sway.package}/bin/sway --config ${swayConfig}";
      };
    in
    {
      enable = true;
      # At boot, then again whenever the session ends
      settings.initial_session = kiosk;
      settings.default_session = kiosk;
    };

  programs.sway = {
    enable = true;
    extraOptions = [ "--unsupported-gpu" ];
    extraPackages = [ ];
    # Composite every frame into Sway's own buffers. With direct scanout, KMS capture
    # reads the game's buffers, which at 120 Hz it sometimes copies out of order.
    extraSessionCommands = ''
      export WLR_SCENE_DISABLE_DIRECT_SCANOUT=1
    '';
  };

  programs.steam.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  # Sunshine's virtual Switch and DualSense controllers.
  boot.kernelModules = [ "uhid" ];

  # Emulate 4k60 display through software. Using edid from px3-pro
  hardware.display = {
    edid.packages = [
      (pkgs.runCommand "edid-px3-pro" { } ''
        install -Dm444 ${./edid/px3-pro.bin} $out/lib/firmware/edid/px3-pro.bin
      '')
    ];
    outputs."HDMI-A-1" = {
      edid = "px3-pro.bin";
      mode = "e";
    };
  };

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
    package = pkgs.sunshine.override { cudaSupport = true; }; # Required for NVENC
    settings = {
      capture = "kms";
      encoder = "nvenc";
      # The web UI only trusts localhost; any port is allowed
      csrf_allowed_origins = "https://totoro.lan,https://totoro";
      global_prep_cmd = builtins.toJSON [
        {
          do = "${streamStart}";
          undo = "${streamEnd}";
        }
      ];
    };

    # Moonlight's tiles. Each runs showOrStart, so reopening a tile focuses the app instead
    # of starting a second copy, and the kiosk makes whatever has the focus fullscreen.
    # To add one, open the app once and match its window's app_id (Wayland) or class (X11):
    #   ssh root@totoro "su games -c 'SWAYSOCK=\$(ls -t /run/user/*/sway-ipc.*.sock | head -n1) swaymsg -t get_tree'"
    applications.apps = [
      {
        name = "Steam";
        image-path = "steam.png";
        detached = [
          (showOrStart "steam" [
            ''[class="steam" title="Steam Big Picture Mode"]''
          ] "steam steam://open/bigpicture")
        ];
      }
      # The game if it's running, else the launcher
      {
        name = "Minecraft";
        image-path = "${prism}/share/icons/hicolor/256x256/apps/org.prismlauncher.PrismLauncher.png";
        detached = [
          (showOrStart "minecraft" [
            ''[class="com.mojang.minecraft"]''
            ''[app_id="org.prismlauncher.PrismLauncher"]''
          ] "${prism}/bin/prismlauncher")
        ];
      }
    ];
  };
}
