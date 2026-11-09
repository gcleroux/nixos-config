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
  # Static on cluster VLAN 30, where node addresses start at .10 / ::10. The IPv6
  # /64 comes from the static /56, so the dual-stack node IP never changes.
  kubeMasterIP = "10.0.30.10";
  kubeMasterIP6 = "2606:6d00:ffb:6630::10";
  clusterGateway = "10.0.30.1"; # calcifer: router, DNS, BGP peer

  podCIDRs = "10.42.0.0/16,2606:6d00:ffb:6680::/60";
  serviceCIDRs = "10.43.0.0/16,fd5e:904f:ae62:43::/112";

  ciliumValues = {
    cluster = {
      name = "homelab";
      id = 1;
    };
    # k3s serves the API on every address, and loopback survives a node re-IP.
    k8sServiceHost = "127.0.0.1";
    k8sServicePort = 6443;
    kubeProxyReplacement = true;
    ipam.mode = "kubernetes"; # node pod ranges come from k3s --cluster-cidr
    ipv4.enabled = true;
    ipv6.enabled = true;
    routingMode = "native";
    autoDirectNodeRoutes = true;
    ipv4NativeRoutingCIDR = "10.42.0.0/16";
    ipv6NativeRoutingCIDR = "2606:6d00:ffb:6680::/60";
    bpf.masquerade = true;
    enableIPv4Masquerade = true;
    enableIPv6Masquerade = false;
    bgpControlPlane.enabled = true;
    operator.replicas = 1;
    hubble.relay.enabled = true;
  };
in
{

  imports = builtins.attrValues outputs.nixosModules;

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
      ensureProfiles.profiles.lan = {
        connection = {
          id = "lan";
          type = "ethernet";
          interface-name = "enp0s13f0u1";
          autoconnect-priority = 10;
        };
        ipv4 = {
          method = "manual";
          address1 = "${kubeMasterIP}/24,${clusterGateway}";
          dns = "${clusterGateway};";
          dns-search = "lan;";
        };
        ipv6 = {
          method = "auto";
          address1 = "${kubeMasterIP6}/64";
          ip6-privacy = 0;
          ignore-auto-dns = true;
        };
      };
    };
    hostName = hostname;

    hosts = lib.mkForce { };
    extraHosts = "${kubeMasterIP} ${hostname}";

    # Disable firewall for faster deployment
    firewall.enable = false;
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

  services.k3s = {
    enable = true;
    role = "server";
    package = pkgs.k3s_1_37; # same Kubernetes minor as the cluster it replaces
    nodeIP = "${kubeMasterIP},${kubeMasterIP6}";
    disable = [
      "traefik"
      "servicelb"
      "local-storage"
      "metrics-server"
      "gateway-api-crd"
    ];
    extraFlags = [
      "--flannel-backend=none"
      "--disable-network-policy"
      "--disable-kube-proxy"
      "--cluster-cidr=${podCIDRs}"
      "--service-cidr=${serviceCIDRs}"
      "--write-kubeconfig-mode=0640"
      "--write-kubeconfig-group=kubernetes"
      "--tls-san=${hostname}"
    ];
    gracefulNodeShutdown.enable = true;
    manifests.cilium.content = {
      apiVersion = "helm.cattle.io/v1";
      kind = "HelmChart";
      metadata = {
        name = "cilium";
        namespace = "kube-system";
      };
      spec = {
        repo = "https://helm.cilium.io";
        chart = "cilium";
        version = "1.20.4";
        targetNamespace = "kube-system";
        bootstrap = true;
        valuesContent = builtins.toJSON ciliumValues;
      };
    };
  };
  # Was created by services.kubernetes; k3s writes its kubeconfig for it.
  users.groups.kubernetes = { };
  # NFS volumes (boot.supportedFilesystems has "nfs").
  services.rpcbind.enable = true;

  system.stateVersion = "24.05";
}
