# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ inputs, config, pkgs, ... }@args:
let username = "guillaume";
in {
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = import ../overlays args;

  nix.settings = {
    # Nix package manager options
    experimental-features = [ "nix-command" "flakes" ];
  };

  # User config
  users.users.${username} = {
    isNormalUser = true;
    extraGroups =
      [ "wheel" "input" "docker" "libvirtd" "qemu-libvirtd" "networkmanager" ];
    shell = pkgs.zsh;
  };

  programs = {
    dconf.enable = true;
    file-roller.enable = true;
    quark-goldleaf.enable = true;

    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    steam.enable = true;
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [ thunar-archive-plugin thunar-volman ];
    };

    zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
    };
  };

  #TODO: Refactor config into modules like this for cleaner repo
  imports = [ ../modules/greeter.nix ];

  services = {
    auto-cpufreq.enable = true;
    blueman.enable = true;
    dbus.enable = true;
    # fprintd.enable = true;
    flatpak.enable = true;
    fwupd.enable = true;
    gnome.gnome-keyring.enable = true;
    mullvad-vpn.enable = true;
    openssh.enable = true;

    # This will prevent laptop from going to sleep when turning off screens
    logind.lidSwitchExternalPower = "ignore";

    # Pipewire settings
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.configPackages = [
        (pkgs.writeTextDir
          "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
            bluez_monitor.properties = {
                ["with-logind"] = false,
            }
          '')
      ];
    };

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

    xserver = {
      enable = true;

      # Libinput gestures
      libinput.enable = true;
      libinput.touchpad.tapping = true;
    };

    # Backup tool setup for the /home directory
    #TODO: Exclude ~/Downloads from backup
    btrbk = {
      instances = {
        daily = {
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
        weekly = {
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
        monthly = {
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

    # This makes swaylock work to unlock session
    pam.services.swaylock = {
      text = ''
        auth include login
      '';
    };
  };

  environment = {
    # Installed packages
    systemPackages = with pkgs; [
      brightnessctl
      btrbk
      clinfo
      cliphist
      coreutils
      dolphin-emu
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
      libsForQt5.kdeconnect-kde
      libsForQt5.polkit-kde-agent
      libsForQt5.qt5.qtwayland
      lutris
      mesa
      networkmanagerapplet
      openconnect
      openvpn
      pciutils
      pipewire
      playerctl
      powerstat
      protonup-qt
      qt6.qtwayland
      rtkit
      slurp
      unzip
      usbutils
      virt-manager
      wacomtablet
      wdisplays
      wget
      wl-clipboard
      xdg-utils
    ];

    # Get completion for system packages
    pathsToLink = [ "/share/zsh" ];

    sessionVariables = { NIXOS_OZONE_WL = "1"; };

  };

  # Installing fonts
  fonts = {
    packages = with pkgs; [
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

  systemd.extraConfig = "DefaultTimeoutStopSec=10s";

  system.stateVersion = "23.05";
}
