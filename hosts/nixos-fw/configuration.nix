{
  inputs,
  config,
  pkgs,
  username,
  hostname,
  outputs,
  ...
}:
{
  host.services = {
    audio = {
      enable = true;
      bluetooth.enable = true;
    };
    backups.enable = true;
    fonts.enable = true;
    gaming.enable = true;
    greeter.enable = true;
    keyring.enable = true;
    polkit.enable = true;
    powersave.enable = true;
    printing.enable = true;
    virtualisation.enable = true;
  };

  # Keeps build dependencies alive, so calcifer can still be rebuilt offline
  nix.settings.keep-outputs = true;

  # User config
  host.users.guillaume = {
    admin = true;
    extraGroups = [
      "input"
      "video"
      "docker"
      "libvirtd"
      "qemu-libvirtd"
      "networkmanager"
    ];
  };

  xdg.portal = {
    enable = true;
    wlr = {
      enable = true;
      settings = {
        screencast = {
          max_fps = 30;
          # exec_before = "${pkgs.fnott}/bin/fnottctl pause";
          # exec_after = "${pkgs.fnott}/bin/fnottctl unpause";
          chooser_type = "simple";
          chooser_cmd = "${pkgs.slurp}/bin/slurp -f 'Monitor: %o' -or";
        };
      };
    };
    config.common = {
      default = [
        "wlr"
        "gtk"
      ];
      "org.freedesktop.impl.portal.Inhibit" = [ "none" ];
    };
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  programs = {
    bazecor.enable = true;
    river-classic.enable = true;
    thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
      ];
    };

    fish.enable = true;
    zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
    };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  services = {
    dbus = {
      enable = true;
      implementation = "broker";
    };
    fwupd.enable = true;
    # Thunar services
    gvfs.enable = true; # Mount, trash, and other functionalities
    tumbler.enable = true; # Thumbnail support for images
    upower.enable = true;
    libinput.enable = true;
  };

  networking = {
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openconnect
        networkmanager-openvpn
      ];
    };
    firewall.enable = false;
  };

  environment = {
    # Installed packages
    systemPackages = with pkgs; [
      brightnessctl
      clinfo
      coreutils
      dex
      file-roller
      gcc
      gdb
      git
      glib
      grim
      imagemagick
      libnotify
      mesa
      mesa-demos
      networkmanagerapplet
      nfs-utils
      openconnect
      openvpn
      p7zip
      pciutils
      playerctl
      powerstat
      rtkit
      slurp
      tpm2-tss
      unzip
      usbutils
      wdisplays
      wget
      wl-clipboard
      xdg-utils
    ];

    pathsToLink = [ "/share/zsh" ];

    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };

  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "10s";
  };

  system.stateVersion = "23.05";
}
