# A declarative PKI for `services.kubernetes`, replacing `easyCerts` (the cfssl +
# certmgr runtime PKI of the NixOS module).
#
# Long-lived material lives in the configuration repository: the public CA
# certificate in plain text, the CA private key and the service-account signing
# key through sops-nix. Everything else is derived on the host by `kube-pki ensure`
# from a spec this module writes from the kubernetes configuration (CNs, SANs, key
# usages, file owners and the units to restart):
#
#   * before any kubernetes unit starts (kubernetes-pki.service),
#   * on every `nixos-rebuild switch` that changes the spec,
#   * daily, from kubernetes-pki-renew.timer.
#
# A certificate is re-issued when it is missing, within the renewal window, no
# longer valid under the CA, or when its subject, SANs or key usage differ from the
# spec; the units that use it are then restarted. Nothing secret is produced at
# build time: the spec in the store only holds names and paths.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.services.kubernetes-pki;
  top = config.services.kubernetes;

  secretsDir = top.secretsPath;
  cert = name: "${secretsDir}/${name}.pem";
  key = name: "${secretsDir}/${name}-key.pem";

  bootstrapped = cfg.caCertFile != null && cfg.caKeyFile != null && cfg.serviceAccountKeyFile != null;

  clusterDomain = top.addons.dns.clusterDomain;
  nodeName = top.kubelet.hostname;
  nodeIP = top.apiserver.advertiseAddress;
  apiserverServiceIP =
    lib.concatStringsSep "." (lib.take 3 (lib.splitString "." top.apiserver.serviceClusterIpRange))
    + ".1";
  isIP = s: builtins.match "[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+" s != null;

  certModule = lib.types.submodule {
    options = {
      cn = lib.mkOption {
        type = lib.types.str;
        description = "Common name of the certificate subject.";
      };
      organizations = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Organization (O) fields of the subject, e.g. kubernetes groups.";
      };
      usages = lib.mkOption {
        type = lib.types.nonEmptyListOf (
          lib.types.enum [
            "server"
            "client"
          ]
        );
        description = "Extended key usages.";
      };
      dnsNames = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "DNS subject alternative names.";
      };
      ipAddresses = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "IP subject alternative names.";
      };
      owner = lib.mkOption {
        type = lib.types.str;
        default = "kubernetes";
        description = "Owner of the private key file.";
      };
      group = lib.mkOption {
        type = lib.types.str;
        default = "kubernetes";
        description = "Group of the private key file.";
      };
      restartUnits = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Systemd units to restart when the certificate is re-issued.";
      };
    };
  };

  # Same file names as easyCerts, so unit files and kubeconfigs keep their paths.
  controlPlaneCerts =
    lib.optionalAttrs top.apiserver.enable {
      kube-apiserver = {
        cn = "kubernetes";
        usages = [ "server" ];
        dnsNames = [
          "kubernetes"
          "kubernetes.default"
          "kubernetes.default.svc"
          "kubernetes.default.svc.${clusterDomain}"
          top.masterAddress
        ]
        ++ lib.filter (s: !isIP s) top.apiserver.extraSANs;
        ipAddresses = [
          apiserverServiceIP
          "127.0.0.1"
        ]
        ++ lib.optional (nodeIP != null) nodeIP
        ++ lib.filter isIP top.apiserver.extraSANs;
        restartUnits = [ "kube-apiserver.service" ];
      };
      kube-apiserver-kubelet-client = {
        cn = "system:kube-apiserver";
        usages = [ "client" ];
        restartUnits = [ "kube-apiserver.service" ];
      };
      kube-apiserver-proxy-client = {
        cn = "front-proxy-client";
        usages = [ "client" ];
        restartUnits = [ "kube-apiserver.service" ];
      };
      kube-apiserver-etcd-client = {
        cn = "etcd-client";
        usages = [ "client" ];
        restartUnits = [ "kube-apiserver.service" ];
      };
      # used by /etc/kubernetes/cluster-admin.kubeconfig and the addon bootstrap (root only)
      cluster-admin = {
        cn = "cluster-admin";
        organizations = [ "system:masters" ];
        usages = [ "client" ];
        owner = "root";
        group = "root";
      };
    }
    // lib.optionalAttrs config.services.etcd.enable {
      etcd = {
        cn = top.masterAddress;
        usages = [
          "server"
          "client"
        ];
        dnsNames = [
          "etcd.local"
          "etcd.${clusterDomain}"
          top.masterAddress
        ];
        ipAddresses = [ "127.0.0.1" ] ++ lib.optional (nodeIP != null) nodeIP;
        owner = "etcd";
        group = "etcd";
        restartUnits = [ "etcd.service" ];
      };
    }
    // lib.optionalAttrs top.controllerManager.enable {
      kube-controller-manager-client = {
        cn = "system:kube-controller-manager";
        usages = [ "client" ];
        restartUnits = [ "kube-controller-manager.service" ];
      };
    }
    // lib.optionalAttrs top.scheduler.enable {
      kube-scheduler-client = {
        cn = "system:kube-scheduler";
        usages = [ "client" ];
        restartUnits = [ "kube-scheduler.service" ];
      };
    }
    // lib.optionalAttrs top.kubelet.enable {
      kubelet = {
        cn = nodeName;
        usages = [ "server" ];
        dnsNames = [ nodeName ];
        ipAddresses = lib.optional (nodeIP != null) nodeIP;
        restartUnits = [ "kubelet.service" ];
      };
      kubelet-client = {
        cn = "system:node:${nodeName}";
        organizations = [ "system:nodes" ];
        usages = [ "client" ];
        restartUnits = [ "kubelet.service" ];
      };
    }
    // lib.optionalAttrs top.proxy.enable {
      kube-proxy-client = {
        cn = "system:kube-proxy";
        usages = [ "client" ];
        restartUnits = [ "kube-proxy.service" ];
      };
    }
    // lib.optionalAttrs config.services.flannel.enable {
      flannel-client = {
        cn = "flannel-client";
        usages = [ "client" ];
        restartUnits = [ "flannel.service" ];
      };
    }
    // lib.optionalAttrs top.addonManager.enable {
      kube-addon-manager = {
        cn = "system:kube-addon-manager";
        usages = [ "client" ];
        restartUnits = [ "kube-addon-manager.service" ];
      };
    };

  spec = {
    inherit secretsDir;
    certs = cfg.certs;
    validityDays = cfg.validityDays;
    renewBeforeSeconds = cfg.renewBeforeDays * 24 * 60 * 60;
    ca = {
      certFile = if cfg.caCertFile != null then "${cfg.caCertFile}" else null;
      keyFile = cfg.caKeyFile;
    };
    serviceAccount = {
      keyFile = cfg.serviceAccountKeyFile;
      owner = "kubernetes";
      group = "kubernetes";
      restartUnits = [
        "kube-apiserver.service"
        "kube-controller-manager.service"
      ];
    };
  };
  specFile = pkgs.writeText "kube-pki-spec.json" (builtins.toJSON spec);
  ensure = "${lib.getExe cfg.package} ensure --spec ${specFile}";

  clientKubeConfig =
    name: certName:
    top.lib.mkKubeConfig name {
      server = top.apiserverAddress;
      certFile = cert certName;
      keyFile = key certName;
    };
  clusterAdminKubeconfig = clientKubeConfig "cluster-admin" "cluster-admin";

  # every unit that reads certificates waits for the PKI job
  dependents =
    lib.optional config.services.etcd.enable "etcd"
    ++ lib.optional top.apiserver.enable "kube-apiserver"
    ++ lib.optional top.controllerManager.enable "kube-controller-manager"
    ++ lib.optional top.scheduler.enable "kube-scheduler"
    ++ lib.optional top.kubelet.enable "kubelet"
    ++ lib.optional top.proxy.enable "kube-proxy"
    ++ lib.optional config.services.flannel.enable "flannel"
    ++ lib.optional top.addonManager.enable "kube-addon-manager";
in
{
  options.host.services.kubernetes-pki = {
    enable = lib.mkEnableOption "the declarative kubernetes PKI (replaces services.kubernetes.easyCerts)";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.kube-pki or (pkgs.callPackage ../../../pkgs/kube-pki/package.nix { });
      defaultText = lib.literalExpression "pkgs.kube-pki";
      description = "The kube-pki package used to issue certificates.";
    };

    caCertFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = lib.literalExpression "./pki/ca.pem";
      description = ''
        The public CA certificate. It is not secret and may live in the Nix store.
        Created with `kube-pki init-ca`. While this (or one of the key files) is
        unset the configuration still evaluates, with a warning, and
        kubernetes-pki.service fails instead of starting the control plane without
        certificates.
      '';
    };

    caKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = lib.literalExpression ''config.sops.secrets."kubernetes/ca-key.pem".path'';
      description = "Runtime path of the CA private key, usually a sops-nix secret.";
    };

    serviceAccountKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = lib.literalExpression ''config.sops.secrets."kubernetes/service-account-key.pem".path'';
      description = ''
        Runtime path of the service-account token signing key, usually a sops-nix
        secret. Changing it invalidates every service-account token in the cluster.
      '';
    };

    validityDays = lib.mkOption {
      type = lib.types.ints.positive;
      default = 365;
      description = "Lifetime of the issued component certificates.";
    };

    renewBeforeDays = lib.mkOption {
      type = lib.types.ints.positive;
      default = 30;
      description = "Re-issue a certificate when it expires within this many days.";
    };

    certs = lib.mkOption {
      type = lib.types.attrsOf certModule;
      default = { };
      description = ''
        Certificates to issue, keyed by file name (`<name>.pem` and `<name>-key.pem`
        under `services.kubernetes.secretsPath`). The control-plane set is added by
        this module from the enabled kubernetes services; add extra ones here or
        override attributes of the defaults.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    warnings = lib.optional (!bootstrapped) ''
      host.services.kubernetes-pki is enabled but not bootstrapped: caCertFile,
      caKeyFile and serviceAccountKeyFile must all be set. Kubernetes will not start
      until you run `nix run .#kube-pki -- init-ca ...`, see docs/kubernetes-pki.md.
    '';

    host.services.kubernetes-pki.certs = lib.mapAttrs (
      _: lib.mapAttrs (_: lib.mkDefault)
    ) controlPlaneCerts;

    services.kubernetes = {
      easyCerts = false;
      caFile = cert "ca";

      apiserver = lib.mkIf top.apiserver.enable {
        tlsCertFile = cert "kube-apiserver";
        tlsKeyFile = key "kube-apiserver";
        kubeletClientCertFile = cert "kube-apiserver-kubelet-client";
        kubeletClientKeyFile = key "kube-apiserver-kubelet-client";
        proxyClientCertFile = cert "kube-apiserver-proxy-client";
        proxyClientKeyFile = key "kube-apiserver-proxy-client";
        serviceAccountKeyFile = cert "service-account"; # public key, derived on the host
        serviceAccountSigningKeyFile = key "service-account";
        etcd = {
          servers = [ "https://etcd.local:2379" ];
          certFile = cert "kube-apiserver-etcd-client";
          keyFile = key "kube-apiserver-etcd-client";
        };
      };
      controllerManager = lib.mkIf top.controllerManager.enable {
        serviceAccountKeyFile = key "service-account";
        kubeconfig = {
          certFile = cert "kube-controller-manager-client";
          keyFile = key "kube-controller-manager-client";
        };
      };
      scheduler = lib.mkIf top.scheduler.enable {
        kubeconfig = {
          certFile = cert "kube-scheduler-client";
          keyFile = key "kube-scheduler-client";
        };
      };
      kubelet = lib.mkIf top.kubelet.enable {
        tlsCertFile = cert "kubelet";
        tlsKeyFile = key "kubelet";
        kubeconfig = {
          certFile = cert "kubelet-client";
          keyFile = key "kubelet-client";
        };
      };
      proxy = lib.mkIf top.proxy.enable {
        kubeconfig = {
          certFile = cert "kube-proxy-client";
          keyFile = key "kube-proxy-client";
        };
      };
    };

    # etcd stays on loopback with the names easyCerts used, so an existing data
    # directory and member list keep working unchanged.
    services.etcd = lib.mkIf config.services.etcd.enable {
      certFile = cert "etcd";
      keyFile = key "etcd";
      trustedCaFile = cert "ca";
      listenClientUrls = [ "https://127.0.0.1:2379" ];
      listenPeerUrls = [ "https://127.0.0.1:2380" ];
      advertiseClientUrls = [ "https://etcd.local:2379" ];
      initialCluster = [ "${top.masterAddress}=https://etcd.local:2380" ];
      initialAdvertisePeerUrls = [ "https://etcd.local:2380" ];
    };
    networking.extraHosts = lib.mkIf config.services.etcd.enable "127.0.0.1 etcd.${clusterDomain} etcd.local";

    services.flannel.kubeconfig = lib.mkIf config.services.flannel.enable (
      clientKubeConfig "flannel" "flannel-client"
    );

    environment.etc = lib.mkMerge [
      { "kubernetes/kube-pki-spec.json".source = specFile; }
      (lib.mkIf top.apiserver.enable {
        "kubernetes/cluster-admin.kubeconfig".source = clusterAdminKubeconfig;
      })
    ];
    environment.systemPackages = [ cfg.package ];

    systemd.services = lib.mkMerge [
      (lib.genAttrs dependents (_: {
        wants = [ "kubernetes-pki.service" ];
        after = [ "kubernetes-pki.service" ];
      }))

      # The addon manager authenticates with its own client certificate; the RBAC
      # bootstrap addons (its own role, the apiserver->kubelet binding, flannel) are
      # applied once at start with the cluster-admin credential, as easyCerts did.
      (lib.mkIf top.addonManager.enable {
        kube-addon-manager = {
          environment.KUBECONFIG = clientKubeConfig "addon-manager" "kube-addon-manager";
          serviceConfig.ExecStartPre = lib.mkIf (top.addonManager.bootstrapAddons != { }) (
            let
              files = lib.mapAttrsToList (
                n: v: pkgs.writeText "${n}.json" (builtins.toJSON v)
              ) top.addonManager.bootstrapAddons;
              bootstrap = pkgs.writeShellScript "kube-addon-manager-bootstrap" ''
                export KUBECONFIG=${clusterAdminKubeconfig}
                exec ${top.package}/bin/kubectl apply ${lib.concatMapStringsSep " " (f: "-f ${f}") files}
              '';
            in
            [ "+${bootstrap}" ]
          );
        };
      })

      {
        kubernetes-pki = {
          description = "Kubernetes PKI: issue and renew certificates";
          wantedBy = [ "kubernetes.target" ];
          unitConfig.RequiresMountsFor = [ secretsDir ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = ensure;
          };
        };
        kubernetes-pki-renew = {
          description = "Kubernetes PKI: daily certificate renewal check";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = ensure;
          };
        };
      }
    ];

    systemd.timers.kubernetes-pki-renew = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "2h";
      };
    };
  };
}
