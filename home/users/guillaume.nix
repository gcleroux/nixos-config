{
  pkgs,
  username,
  outputs,
  ...
}:
{
  imports =
    # Option modules (user.*); toggled per host.
    builtins.attrValues outputs.homeManagerModules
    # Always-on, headless-safe configuration.
    ++ [
      ../programs/bat
      ../programs/bottom
      ../programs/direnv
      ../programs/fish
      ../programs/foot
      ../programs/fzf
      ../programs/git
      ../programs/lazygit
      ../programs/neovim
      ../programs/ssh
      ../programs/starship
      ../programs/tmux
      ../programs/zsh
    ];

  programs.delta = {
    enable = true;
    options.navigate = true;
  };
  programs.eza.enable = true;
  programs.ripgrep.enable = true;
  programs.yazi.enable = true;
  programs.yazi.shellWrapperName = "yy";
  # programs.zellij.enable = true;
  programs.zoxide.enable = true;

  # This will automatically import SSH keys as age keys
  sops.age.sshKeyPaths = [ "/home/${username}/.ssh/id_ed25519" ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.sessionPath = [ "$HOME/go/bin" ];
  home.sessionVariables = {
    TERMINAL = "foot";
  };

  # Installed packages
  home.packages = with pkgs; [
    age
    clipboard-jh
    dig
    fd
    fluxcd
    fusee-nano
    gh
    gnumake
    go
    hey
    inetutils
    jq
    k9s
    killall
    kubectl
    kubelogin-oidc
    kubernetes-helm
    kubie
    kustomize
    rclone
    sops
    traceroute
    yq-go
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";
}
