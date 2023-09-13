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
      # TODO: Eventually use kanshi to manage displays dynamically
      lidon = ''
        hyprctl keyword monitor "eDP-1, preferred, 0x0, 1.5"; 
        hyprctl keyword monitor "DP-3, disable"; 
        hyprctl keyword monitor "DP-4, disable"
      '';
      lidoff = ''
        hyprctl keyword monitor "eDP-1, disable"; 
        hyprctl keyword DP-4,preferred,0x0,1.75";
        hyprctl keyword "DP-3,preferred,2194x0,1.75"
      '';
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
