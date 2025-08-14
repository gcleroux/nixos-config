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
  imports = builtins.attrValues outputs.nixosModules;

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

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      outputs.overlays.default
    ];
  };
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings = {
      # Nix package manager options
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  # User config
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "input"
      "video"
      "docker"
      "libvirtd"
      "qemu-libvirtd"
      "networkmanager"
    ];
    shell = pkgs.zsh;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
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
    file-roller.enable = true;
    river.enable = true;
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
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
    openssh.enable = true;

    # Thunar services
    gvfs.enable = true; # Mount, trash, and other functionalities
    tumbler.enable = true; # Thumbnail support for images
    upower.enable = true;
    libinput.enable = true;
  };

  networking = {
    hostName = hostname;
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openconnect
        networkmanager-openvpn
      ];
    };
    firewall.enable = false;
  };

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  environment = {
    # Installed packages
    systemPackages = with pkgs; [
      brightnessctl
      clinfo
      coreutils
      dex
      gcc
      gdb
      git
      glib
      glxinfo
      grim
      imagemagick
      libnotify
      mesa
      networkmanagerapplet
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
