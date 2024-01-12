# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:
let username = "guillaume";
in {
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    # Nix package manager options
    experimental-features = [ "nix-command" "flakes" ];
    # Enabling hyprland cache server
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys =
      [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  # User config
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "input" "docker" "libvirtd" "qemu-libvirtd" ];
    shell = pkgs.zsh;
  };

  programs = {
    dconf.enable = true;
    file-roller.enable = true;

    hyprland = {
      enable = true;
      enableNvidiaPatches = false;
      xwayland.enable = true;
    };

    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [ thunar-archive-plugin thunar-volman ];
    };

    zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
    };
  };

  services = {
    auto-cpufreq.enable = true;
    blueman.enable = true;
    dbus.enable = true;
    flatpak.enable = true;
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
    };

    # Printing settings
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns = true;
      # for a WiFi printer
      openFirewall = true;
    };

    # Thunar services
    gvfs.enable = true; # Mount, trash, and other functionalities
    tumbler.enable = true; # Thumbnail support for images

    # Extra rule for Goldleaf
    udev.extraRules = ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="3000", GROUP="wheel"
    '';
    udev.packages = [ pkgs.bazecor ];

    xserver = {
      enable = true;

      # Libinput gestures
      libinput.enable = true;
      libinput.touchpad.tapping = true;

      displayManager = {
        lightdm.enable = true;
        defaultSession = "hyprland";
        autoLogin.enable = true;
        autoLogin.user = "${username}";
      };
    };

    # Backup tool setup for the /home directory
    #TODO: Exclude ~/Downloads from backup
    btrbk = {
      extraPackages = with pkgs; [ btrfs-progs mbuffer openssh ];
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

  # This allows screensharing on wlr compositors using pipewire
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    wlr.enable = true;
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
      auto-cpufreq
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
      mesa
      networkmanagerapplet
      openconnect
      openvpn
      pciutils
      pipewire
      playerctl
      powerstat
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

    etc = {
      "wireplumber/bluetooth.lua.d/50-bluez-config.lua".text =
        "	bluez_monitor.properties = {\n		[\"with-logind\"] = false,\n	}\n";
    };
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

  system.stateVersion = "23.05";
}
