{ pkgs, ... }: {

  # Required packages for oh-my-zsh plugins
  home.packages = with pkgs; [ autojump ];

  programs.zsh = {
    enable = true;
    initExtra = ''
      # Sourcing trashy here is a bit of a hack, but it works for completions
      source <(trashy completions zsh)

      ${builtins.readFile ./nnn_zsh_cd.sh}
    '';
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

      k = "kubectl";

      # TODO: This path should be tracked somewhere
      nixconf = "cd ~/.nix/nixos-config && nvim";
      nr = "sudo nixos-rebuild --flake ~/.nix/nixos-config";
      # Need impure since the config depends on secrets with sops-nix
      hm = "home-manager --flake ~/.nix/nixos-config";
      ns = "nix-shell -p";
      search = "nix search nixpkgs";

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
