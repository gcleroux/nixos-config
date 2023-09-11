# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:
let inherit (import ../config.nix) user;
in {
  # Nix package manager options
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # User config
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "input" "docker" "libvirtd" "qemu-libvirtd" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;
  programs.hyprland = {
    enable = true;
    nvidiaPatches = false;
    xwayland.enable = true;
  };

  networking = {
    hostName = "nixos-fw"; # Define your hostname.
    networkmanager.enable =
      true; # Easiest to use and most distros use this by default.
    firewall.enable = false;
  };

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  services = {
    dbus.enable = true;
    # Enable the X11 windowing system.
    xserver = {
      enable = true;

      # Libinput gestures
      libinput.enable = true;
      libinput.touchpad.tapping = true;

      desktopManager = { plasma5.enable = true; };

      displayManager = {
        lightdm.enable = true;
        #        autoLogin.enable = true;
        #       autoLogin.user = "${user}";
      };
    };

    blueman.enable = true;

    # Pipewire config
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # Enabling flatpak
    flatpak.enable = true;

    # Enable CUPS to print documents.
    printing.enable = true;

    # Launching systemd services
    openssh.enable = true;
    auto-cpufreq.enable = true;
    mullvad-vpn.enable = true;
    teamviewer.enable = true;

    # Backup tool setup for the /home directory
    btrbk = {
      extraPackages = with pkgs; [ btrfs-progs mbuffer openssh ];
      instances.daily = {
        onCalendar = "daily";
        settings = {
          snapshot_preserve = "14d";
          snapshot_preserve_min = "7d";
          volume = {
            "/" = {
              subvolume = { "home" = { snapshot_create = "always"; }; };
              snapshot_dir = "/.snapshots/daily";
            };
          };
        };
      };
      instances.weekly = {
        onCalendar = "weekly";
        settings = {
          snapshot_preserve = "5w";
          snapshot_preserve_min = "3w";
          volume = {
            "/" = {
              subvolume = { "home" = { snapshot_create = "always"; }; };
              snapshot_dir = "/.snapshots/weekly";
            };
          };
        };
      };
      instances.monthly = {
        onCalendar = "monthly";
        settings = {
          snapshot_preserve = "3m";
          snapshot_preserve_min = "2m";
          volume = {
            "/" = {
              subvolume = { "home" = { snapshot_create = "always"; }; };
              snapshot_dir = "/.snapshots/monthly";
            };
          };
        };
      };
    };
  };

  sound.enable = true;
  # This allows screensharing on wlr compositors using pipewire
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    wlr.enable = true;
  };

  # Hardware config
  hardware = {
    bluetooth.enable = true;

    # GPU hardware acceleration
    opengl = {
      enable = true;

      extraPackages = with pkgs; [
        intel-compute-runtime
        intel-media-driver
        libvdpau-va-gl
      ];
    };

    logitech.wireless.enable = true;
    logitech.wireless.enableGraphical = true;
  };

  virtualisation = {
    # Enable docker
    docker = {
      enable = true;
      storageDriver = "btrfs";
    };
    # Enable KVM virtualisation
    libvirtd.enable = true;
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    pam.services.lightdm.enableKwallet = true;
  };

  # Installed packages
  environment.systemPackages = with pkgs; [
    auto-cpufreq
    btrbk
    clinfo
    copyq
    coreutils
    dolphin-emu
    gcc
    gdb
    glxinfo
    gromit-mpx
    imagemagick
    libguestfs
    libsForQt5.kdeconnect-kde
    mesa
    openconnect
    openvpn
    pciutils
    pipewire
    powerstat
    python311
    python311Packages.pip
    rtkit
    teamviewer
    usbutils
    unzip
    virt-manager
    wacomtablet
    wget
    xclip

    # Hyprland pkgs
    xdg-utils
    wdisplays
    pcmanfm
    waybar
    libnotify
    rofi-wayland
    imv
    networkmanagerapplet
    wl-clipboard
    grim
    slurp
    libsForQt5.qt5.qtwayland
    qt6.qtwayland
    libsForQt5.polkit-kde-agent
    webcord
    pavucontrol
    brightnessctl
    playerctl
    cliphist
  ];

  # Removed unused KDE packages
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    elisa
    khelpcenter
    oxygen
    sddm
  ];

  # Get completion for system packages
  environment.pathsToLink = [ "/share/zsh" ];

  environment.sessionVariables = {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";

    NIXOS_OZONE_WL = "1";
  };

  environment.etc = {
    "wireplumber/bluetooth.lua.d/50-bluez-config.lua".text =
      "	bluez_monitor.properties = {\n		[\"with-logind\"] = false,\n	}\n";
  };

  # Installing fonts
  fonts = {
    fonts = with pkgs; [
      # Nerd fonts
      (nerdfonts.override { fonts = [ "Cousine" "Hack" "FiraCode" "Noto" ]; })

      # System fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
      noto-fonts-extra
    ];
  };

  system.stateVersion = "23.05";
}
