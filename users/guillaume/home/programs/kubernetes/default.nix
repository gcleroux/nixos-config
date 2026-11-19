{ pkgs, ... }:
{
  # fish integration: per-shell contexts (kcx, kns) and the kubectl aliases
  imports = [ ./fish.nix ];

  home.packages = with pkgs; [
    fluxcd
    k9s
    kind
    kubectl
    kubelogin-oidc
    kubernetes-helm
    kustomize
  ];
}
