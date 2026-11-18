{ pkgs, ... }:
{
  imports = [
    ./programs/ai
    ./programs/direnv
    ./programs/lazygit
    ./programs/neovim
    ./programs/ssh
    ./programs/yazi
  ];

  home.sessionPath = [ "$HOME/go/bin" ];

  home.packages = with pkgs; [
    age
    fluxcd
    fusee-nano
    gh
    gnumake
    go
    hey
    k9s
    kubectl
    kubelogin-oidc
    kubernetes-helm
    kubie
    kustomize
    rclone
    sops
  ];
}
