# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable KVM virtualisation
  virtualisation.libvirtd.enable = true;
  boot.extraModprobeConfig = "options kvm_intel nested=1";
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Nix package manager options
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # User config
  users.users.guillaume = {
    isNormalUser = true;
    extraGroups = [ "wheel" "input" "docker" "libvirtd" "qemu-libvirtd" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

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

  system.stateVersion = "23.05";
}