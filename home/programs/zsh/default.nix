{ pkgs, ... }: {

  # Required packages for oh-my-zsh plugins
  home.packages = with pkgs; [ autojump ];

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    shellAliases = {
      # Bat aliases
      cat = "bat";
      man = "batman";
      diff = "batdiff";
      grep = "batgrep";

      lg = "lazygit";
      v = "nvim";

      gc = "git clone";
      gs = "git status";

      # TODO: This path should be tracked somewhere
      nixconf = "cd ~/.nix/nixos-config && nvim .";
      nixup = "sudo nixos-rebuild switch --flake ~/.nix/nixos-config";
      hmup = "home-manager switch --flake ~/.nix/nixos-config";
      ns = "nix-shell -p";

      # Hyprland aliases
      lidon = "hyprctl keyword monitor 'eDP-1, preferred, 4388x0, 1.5'";
      lidoff = "hyprctl keyword monitor 'eDP-1, disable'";
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
