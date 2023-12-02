{ pkgs, ... }: {

  # Required packages for oh-my-zsh plugins
  home.packages = with pkgs; [ autojump ];

  programs.zsh = {
    enable = true;
    initExtra = builtins.readFile ./nnn_zsh_cd.sh;
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
      nnn = "nnn -deo";

      gc = "git clone";
      gs = "git status";

      # TODO: This path should be tracked somewhere
      nixconf = "cd ~/.nix/nixos-config && nvim";
      nixup = "sudo nixos-rebuild switch --flake ~/.nix/nixos-config";
      # Need impure since the config depends on secrets with sops-nix
      hmup = "home-manager switch --impure --flake ~/.nix/nixos-config";
      ns = "nix-shell -p";
      search = "nix search nixpkgs";

      # Hyprland aliases
      # TODO: Eventually use kanshi to manage displays dynamically once it works
      dpon = ''
        hyprctl keyword monitor "eDP-1, preferred, 0x0, 1.5"; 
        hyprctl keyword monitor "DP-3, disable"; 
        hyprctl keyword monitor "DP-4, disable"
      '';
      dpoff = ''
        hyprctl keyword monitor "DP-4,preferred,0x0,1.75";
        hyprctl keyword monitor "DP-3,preferred,2194x0,1.75"
        hyprctl keyword monitor "eDP-1, disable"; 
      '';
      hyprlog =
        "cat /tmp/hypr/$(ls -snew /tmp/hypr | tail -n 2 | head -n 1)/hyprland.log";
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
