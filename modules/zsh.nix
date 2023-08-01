 { 
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
}
