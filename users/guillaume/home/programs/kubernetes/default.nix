{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fluxcd
    k9s
    kind
    kubectl
    kubelogin-oidc
    kubernetes-helm
    kubie
    kustomize
  ];
}
