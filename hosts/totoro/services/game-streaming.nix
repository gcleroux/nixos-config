{
  config,
  lib,
  pkgs,
  ...
}:
let
  swaymsg = "${config.programs.sway.package}/bin/swaymsg";

  # A kiosk on the HDMI dummy plug: whichever window has the focus fills the screen
  swayConfig = pkgs.writeText "sway-games.conf" ''
    # Starts graphical-session.target, which Sunshine waits for
    include /etc/sway/config.d/*

    output HDMI-A-1 mode 1920x1080@119.879Hz
    default_border none
    # A window that asks for the focus gets it, e.g. a game resumed from Big Picture
    focus_on_window_activation focus
    for_window [all] fullscreen enable
    exec ${fullscreenFocused}

    exec steam -gamepadui
  '';

  # Only one window can be fullscreen, and Sway doesn't hand it back when that window
  # closes or loses the focus: the others would tile side by side. Give it to the focused one.
  fullscreenFocused = pkgs.writeShellScript "kiosk-fullscreen-focused" ''
    ${swaymsg} -t subscribe -m -r '["window"]' |
      ${pkgs.gnugrep}/bin/grep --line-buffered -E '^\{ "change": "(focus|close)"' |
      while read -r _; do ${swaymsg} fullscreen enable >/dev/null; done
  '';

  # A Moonlight tile: brings the first open window matching the criteria to the front, or
  # starts the app if none is open. Finds Sway's socket itself, as Sunshine outlives sessions.
  showOrStart =
    name: criteria: start:
    pkgs.writeShellScript "show-${name}" ''
      SWAYSOCK=$(ls -t "$XDG_RUNTIME_DIR"/sway-ipc.*.sock | head -n 1)
      export SWAYSOCK
      for c in ${lib.escapeShellArgs criteria}; do
        ${swaymsg} "$c focus" >/dev/null 2>&1 && exit 0
      done
      exec ${pkgs.util-linux}/bin/setsid ${start}
    '';

  # Minecraft: Java Edition, signed in with the Microsoft account that owns it
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

  # Proton comes with it
  programs.steam.enable = true;

  # Sunshine streams the session's sound
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  # Sunshine's virtual Switch and DualSense controllers. /dev/uhid only gets Sunshine's
  # udev permissions once the module is loaded.
  boot.kernelModules = [ "uhid" ];

  services.sunshine = {
    enable = true;
    autoStart = true;
    # KMS capture reads the display's buffers straight from the GPU. wlr capture
    # (screencopy from Sway) keeps frames in order but tops out at 60 fps here.
    capSysAdmin = true;
    openFirewall = true;
    # NVENC needs CUDA
    package = pkgs.sunshine.override { cudaSupport = true; };
    settings = {
      capture = "kms";
      encoder = "nvenc";
      # The web UI only trusts localhost; any port is allowed
      csrf_allowed_origins = "https://totoro.lan,https://totoro";
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
