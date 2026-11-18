{
  pkgs,
  username,
  hostname,
  ...
}:
{
  imports = [
    ./programs/direnv
    ./programs/fish/kubernetes.nix
    ./programs/lazygit
    ./programs/ssh
  ];

  wrappers.neovim = {
    enable = true;

    # Which flake nixd should evaluate for option completion is per machine,
    # so it cannot live in the neovim flake.
    settings.nixd = {
      nixpkgs = ''import (builtins.getFlake "/etc/nixos").inputs.nixpkgs { }'';
      nixos = ''(builtins.getFlake "/etc/nixos").nixosConfigurations.${hostname}.options'';
      home_manager = ''(builtins.getFlake "/etc/nixos").nixosConfigurations.${hostname}.options.home-manager.users.type.getSubOptions [ ]'';
    };
  };

  programs.git.signing = {
    format = "openpgp";
    signByDefault = true;
    key = "32330E3EDCF4D898";
  };

  user.programs.ai.enable = true;

  programs.yazi.enable = true;
  programs.yazi.shellWrapperName = "yy";

  # This will automatically import SSH keys as age keys
  sops.age.sshKeyPaths = [ "/home/${username}/.ssh/id_ed25519" ];

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
