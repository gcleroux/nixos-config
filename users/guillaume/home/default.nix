{ config, ... }:
{
  imports = [
    ./programs/bash
    ./programs/bat
    ./programs/bottom
    ./programs/cli-tools
    ./programs/eza
    ./programs/fish
    ./programs/fzf
    ./programs/git
    ./programs/network-tools
    ./programs/ripgrep
    ./programs/starship
    ./programs/zoxide
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
  };

  # This will automatically import SSH keys as age keys
  sops.age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
}
