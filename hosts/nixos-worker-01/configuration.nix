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

  # Address plan and stages: docs/network.md in the flux-fleet repository.
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
    # Until calcifer routes the pod /60 to the node over BGP (stage 2).
    enableIPv6Masquerade = true;
    bgpControlPlane.enabled = true; # dormant until a CiliumBGPClusterConfig exists
    operator.replicas = 1;
    hubble.relay.enabled = true;
  };
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

  services.k3s = {
    enable = true;
    role = "server";
    package = pkgs.k3s_1_37; # same Kubernetes minor as the cluster it replaces
    nodeIP = "${kubeMasterIP},${kubeMasterIP6}";
    disable = [
      "traefik" # Envoy Gateway
      "servicelb" # MetalLB, then Cilium
      "local-storage" # openebs-hostpath is the default StorageClass
      "metrics-server" # deployed by Flux in monitoring
    ];
    extraFlags = [
      # Cilium replaces flannel, the network policy controller and kube-proxy.
      "--flannel-backend=none"
      "--disable-network-policy"
      "--disable-kube-proxy"
      # Dual-stack can only be set when the cluster is created.
      "--cluster-cidr=${podCIDRs}"
      "--service-cidr=${serviceCIDRs}"
      "--write-kubeconfig-mode=0640"
      "--write-kubeconfig-group=kubernetes"
      "--tls-san=${hostname}"
    ];
    gracefulNodeShutdown.enable = true;
    # The node has no network until Cilium runs, so k3s installs it from the host
    # network (bootstrap) instead of Flux. Upgrade Cilium here.
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

  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
  };

  system.stateVersion = "24.05";
}
