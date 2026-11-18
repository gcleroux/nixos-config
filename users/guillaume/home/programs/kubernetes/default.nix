{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fluxcd
    k9s
    kubectl
    kubelogin-oidc
    kubernetes-helm
    kubie
    kustomize
  ];
}
