{ config, pkgs, ... }:

{
  imports = [
    ../../modules/starship.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "guillaume";
  home.homeDirectory = "/home/guillaume";

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    shellAliases = {
      icat = "kitty +kitten icat";
      lg = "lazygit";
      kssh = "kitty +kitten ssh";
      v = "nvim";
      ls = "exa";
      ll = "exa -alh";
      tree = "exa --tree";
      cat = "bat -p";
      update = "sudo nixos-rebuild switch --flake ~/nixos-config";
    };
    history = {
      size = 10000;
      path = "$HOME/.zsh_history";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "autojump" ];
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
