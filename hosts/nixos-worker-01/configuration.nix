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
  # Fixed address in the LAN /64 of the static /56, for the dual-stack node IP.
  kubeMasterIP6 = "2606:6d00:ffb:6600::20";
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

  imports = builtins.attrValues outputs.nixosModules;

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
    networkmanager = {
      enable = true;
      # IPv4 comes from a static lease in calcifer's dnsmasq. IPv6 keeps SLAAC
      # and adds kubeMasterIP6, without temporary addresses.
      ensureProfiles.profiles.lan = {
        connection = {
          id = "lan";
          type = "ethernet";
          interface-name = "enp0s13f0u1";
          autoconnect-priority = 10;
        };
        ipv4.method = "auto";
        ipv6 = {
          method = "auto";
          address1 = "${kubeMasterIP6}/64";
          ip6-privacy = 0;
        };
      };
    };
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
      nfs-utils
      pciutils
      powerstat
      usbutils
      wget
    ];
  };

  # etcd 3.6 renamed `--experimental-peer-skip-client-san-verification` to
  # `--peer-skip-client-san-verification`; the old name is dropped in etcd 3.7.
  # (extraConf keys get the ETCD_ prefix in the unit environment.)
  services.etcd.extraConf.PEER_SKIP_CLIENT_SAN_VERIFICATION = "true";

  services.kubernetes = {
    roles = [
      "master"
      "node"
    ];
    masterAddress = hostname;
    apiserverAddress = "https://${hostname}:${toString kubeMasterAPIServerPort}";
    # Certificates come from ./kubernetes-pki.nix (host.services.kubernetes-pki).
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
