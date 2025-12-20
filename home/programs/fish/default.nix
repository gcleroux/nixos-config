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
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "......" = "cd ../../../../..";

      # Bat aliases
      bat = "bat -p";
      ban = "batman";
      biff = "batdiff";
      brep = "batgrep";

      f = "yazi";
      g = "lazygit";
      v = "nvim";

      nnn = "nnn -deo";

      gc = "git clone";
      gs = "git status";

      nixconf = "cd /etc/nixos";
      nr = {
        position = "anywhere";
        expansion = "nixos-rebuild --flake /etc/nixos#";
      };
      ns = "nix-shell -p";
      search = "nix search nixpkgs";
    };
  };
}
