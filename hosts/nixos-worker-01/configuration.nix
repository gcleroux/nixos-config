# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  inputs,
  config,
  lib,
  pkgs,
  username,
  hostname,
  outputs,
  ...
}:
let
  kubeMasterIP = "10.0.0.20";
  kubeMasterAPIServerPort = 6443;

  nixpkgsCoreDNSFix = import (pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "ee09932cedcef15aaf476f9343d1dea2cb77e261";
    sha256 = "sha256-9glbI7f1uU+yzQCq5LwLgdZqx6svOhZWkd4JRY265fc=";
  }) { inherit (pkgs) system; };
  corednsFix = nixpkgsCoreDNSFix.coredns;
in
{

  # host.services.virtualisation.enable = true;

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
      trusted-users = [
        "root"
        "guillaume"
      ];
    };
  };

  networking = {
    networkmanager.enable = true;
    hostName = hostname;

    hosts = lib.mkForce { };
    extraHosts = "${kubeMasterIP} ${hostname}";

    # Disable firewall for faster deployment
    firewall.enable = false;
    # firewall.allowedTCPPorts = [
    #   kubeMasterAPIServerPort
    #
    #   # k8s-gateway
    #   31000
    #
    #   # ingress-nginx
    #   32001
    #   32002
    # ];
  };

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "kubernetes"
    ];
    createHome = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICS77iyKWFPGfozY/N0daz6d9uEXhpdSVpsTTIkBbcRg guillaume@nixos-fw"
    ];
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
  };
  # Enable passwordless config
  security = {
    sudo.enable = true;
    pam = {
      sshAgentAuth.enable = true;
      services.sudo.sshAgentAuth = true;
    };
  };

  programs.fish.enable = true;

  environment = {
    # Installed packages
    systemPackages = with pkgs; [
      bottom
      kompose
      kubernetes
      kubectl
      clinfo
      foot
      fluxcd
      git
      glib
      k9s
      mesa
      mesa-demos
      neovim
      pciutils
      powerstat
      usbutils
      wget
    ];
  };

  systemd.services.etcd.environment.EXPERIMENTAL_PEER_SKIP_CLIENT_SAN_VERIFICATION = "true";
  services.etcd.extraConf."EXPERIMENTAL_PEER_SKIP_CLIENT_SAN_VERIFICATION" = "true";

  services.kubernetes = {
    roles = [
      "master"
      "node"
    ];
    masterAddress = hostname;
    apiserverAddress = "https://${hostname}:${toString kubeMasterAPIServerPort}";
    easyCerts = true;
    apiserver = {
      securePort = kubeMasterAPIServerPort;
      advertiseAddress = kubeMasterIP;
      allowPrivileged = true;
      serviceClusterIpRange = "10.0.0.0/24";
    };
    addons.dns = {
      enable = true;
      corednsImage = nixpkgsCoreDNSFix.dockerTools.buildImage {
        name = "coredns";
        config.Entrypoint = [ "${corednsFix}/bin/coredns" ];
      };
    };
  };
  services.coredns.package = corednsFix;

  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
  };

  system.stateVersion = "24.05";
}
