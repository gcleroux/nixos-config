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

  # The admin age key (.sops.yaml) decrypts the home-manager secrets
  sops.age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
}
