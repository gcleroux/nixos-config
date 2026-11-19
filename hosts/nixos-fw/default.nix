{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./disks.nix
    ./interfaces.nix
    ./desktop.nix

    ./services
  ];

  # Keeps build dependencies alive, so calcifer can still be rebuilt offline
  nix.settings.keep-outputs = true;

  # User config
  host.users.guillaume = {
    admin = true;
    profiles = [
      "dev"
      "desktop"
    ];
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
      dex
      file-roller
      gcc
      gdb
      glib
      grim
      imagemagick
      libnotify
      mesa-demos
      openconnect
      openvpn
      p7zip
      playerctl
      slurp
      tpm2-tss
      unzip
      wdisplays
      wl-clipboard
    ];
  };

  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "10s";
  };

  system.stateVersion = "23.05";
}
