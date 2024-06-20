{ pkgs, config, ... }:
let
  kubectl = rec {
    source = ./kubectl_aliases;
    target = "fish/kubectl_aliases";
    path = "${config.xdg.configHome}/${target}";
  };
in
{
  # Load the kubectl_aliases in $XDG_CONFIG_HOME
  xdg.configFile.kubectl_aliases = {
    inherit (kubectl) source target;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Disable greeting
      set fish_greeting

      # Load the kubectl_aliases file
      source (cat ${kubectl.path} | sed -r 's/(kubectl.*) --watch/watch \1/g' | psub)
    '';
    shellAbbrs = {
      # Bat aliases
      cat = "bat -p";
      man = "batman";
      diff = "batdiff";
      grep = "batgrep";

      f = "yazi";
      g = "lazygit";
      v = "nvim";

      nnn = "nnn -deo";

      gc = "git clone";
      gs = "git status";

      # TODO: This path should be tracked somewhere
      nixconf = "cd ~/.nix/nixos-config && nvim";
      nr = "sudo nixos-rebuild --flake ~/.nix/nixos-config";
      # Need impure since the config depends on secrets with sops-nix
      hm = "home-manager --flake ~/.nix/nixos-config";
      ns = "nix-shell -p";
      search = "nix search nixpkgs";
    };
  };
}
# [ -f ${config.xdg.configHome}/fish/kubectl_aliases ] && source \
#    <(cat ${config.xdg.configHome}/fish/kubectl_aliases | sed -r 's/(kubectl.*) --watch/watch \1/g')
