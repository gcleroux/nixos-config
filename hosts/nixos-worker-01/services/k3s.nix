{
  pkgs,
  hostname,
  inventory,
  ...
}:
let
  addr = inventory.hosts.${hostname};
  inherit (inventory.cidrs) pods4 pods6;

  podCIDRs = "${pods4},${pods6}";
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
    ipv4NativeRoutingCIDR = pods4;
    ipv6NativeRoutingCIDR = pods6;
    bpf.masquerade = true;
    enableIPv4Masquerade = true;
    enableIPv6Masquerade = false;
    bgpControlPlane.enabled = true;
    operator.replicas = 1;
    hubble.relay.enabled = true;
  };
in
{
  services.k3s = {
    enable = true;
    role = "server";
    package = pkgs.k3s_1_37; # same Kubernetes minor as the cluster it replaces
    nodeIP = "${addr.cluster4},${addr.cluster6}";
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
}
