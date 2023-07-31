# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Nix package manager options
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # User config
  users.users.guillaume = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
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
    # Enable the X11 windowing system.
    xserver = {
      enable = true;

      # Libinput gestures
      libinput.enable = true;
      libinput.touchpad.tapping = true;

      desktopManager = { plasma5.enable = true; };

      displayManager = {
        lightdm.enable = true;
        autoLogin.enable = true;
        autoLogin.user = "guillaume";
        defaultSession = "plasmawayland";
      };
    };

    # Pipewire config
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Enable CUPS to print documents.
    printing.enable = true;

    # Launching systemd services
    openssh.enable = true;
    auto-cpufreq.enable = true;
  };

  # This allows screensharing on wlr compositors using pipewire
  xdg.portal.wlr.enable = true;

  # Hardware config
  hardware = {
    bluetooth.enable = true;

    # GPU hardware acceleration
    opengl.extraPackages = with pkgs; [
      intel-compute-runtime
      intel-media-driver
    ];
  };

  # Enabling docker
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
  };

  security = {
    rtkit.enable = true;
    pam.services.lightdm.enableKwallet = true;
  };

  # Installed packages
  environment.systemPackages = with pkgs; [
    auto-cpufreq
    autojump
    bat
    bitwarden
    bitwarden-cli
    btop
    cargo
    clinfo
    coreutils
    exa
    firefox
    gcc
    gdb
    gh
    gimp
    git
    glxinfo
    go
    imagemagick
    kitty
    krita
    lazygit
    libreoffice-qt
    libsForQt5.kdeconnect-kde
    luajitPackages.luarocks
    mesa
    moonlight-qt
    mullvad-vpn
    neofetch
    nixfmt
    nodePackages.npm
    nodejs-slim_20
    obs-studio
    obsidian
    openconnect
    openvpn
    parsec-bin
    pciutils
    pipewire
    powerstat
    python311
    python311Packages.pip
    qbittorrent
    ripgrep
    rtkit
    signal-desktop
    spotify
    starship
    teams
    teamviewer
    thunderbird-bin
    timeshift
    usbutils
    ungoogled-chromium
    unzip
    vlc
    webcord
    wget
    wl-clipboard
    wlr-randr
    xorg.xeyes
    zsh
  ];

  # Removed unused KDE packages
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    elisa
    khelpcenter
    oxygen
    sddm
  ];

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

  # Enabling programs
  programs = {
    mtr.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    zsh.enable = true;

    neovim = {
      enable = true;
      defaultEditor = true;
    };
  };

  # Session variables
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

