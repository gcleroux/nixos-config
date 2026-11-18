{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./disks.nix
    ./interfaces.nix
    ./desktop.nix
    ./home.nix
  ];

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

  programs.bazecor.enable = true;
  services.fwupd.enable = true;

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
  };

  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "10s";
  };

  system.stateVersion = "23.05";
}
