{
  inputs,
  config,
  pkgs,
  username,
  ...
}@args:
{
  #TODO: Refactor config into modules like this for cleaner repo
  imports = [
    ../modules/backups
    ../modules/bluetooth
    ../modules/ddcci
    ../modules/fonts
    ../modules/greeter
    ../modules/pipewire
    ../modules/polkit
    ../modules/powersave
    ../modules/virtualisation
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = import ../overlays args;

  nix.settings = {
    # Nix package manager options
    experimental-features = [
      "nix-command"
      "flakes"
    ];
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
    config.common.default = [
      "wlr"
      "gtk"
    ];
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  programs = {
    file-roller.enable = true;
    # kdeconnect.enable = true;
    quark-goldleaf.enable = true;
    river.enable = true;

    seahorse.enable = true;
    steam.enable = true;
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };

    zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
    };
  };

  services = {
    dbus.enable = true;
    fwupd.enable = true;
    gnome.gnome-keyring.enable = true;
    mullvad-vpn.enable = true;
    openssh.enable = true;
    udev.packages = with pkgs; [ bazecor ];

    # Printing settings
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      # for a WiFi printer
      openFirewall = true;
    };

    # Thunar services
    gvfs.enable = true; # Mount, trash, and other functionalities
    tumbler.enable = true; # Thumbnail support for images
    upower.enable = true;
    libinput.enable = true;
  };

  networking = {
    hostName = "nixos-fw"; # Define your hostname.
    networkmanager.enable = true;
    firewall.enable = false;
  };

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # This makes swaylock work to unlock session
  security.pam.services.swaylock = { };

  environment = {
    # Installed packages
    systemPackages = with pkgs; [
      brightnessctl
      clinfo
      cliphist
      coreutils
      gcc
      gdb
      git
      glib
      glxinfo
      grim
      home-manager
      imagemagick
      libguestfs
      libnotify
      lutris
      mesa
      networkmanagerapplet
      openconnect
      openvpn
      p7zip
      pciutils
      playerctl
      powerstat
      protonup-qt
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

    # Get completion for system packages
    pathsToLink = [ "/share/zsh" ];

    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };

  systemd.extraConfig = "DefaultTimeoutStopSec=10s";

  system.stateVersion = "23.05";
}
