let
  more = { pkgs, ... }: {
    programs.exa = {
      enable = true;
      enableAliases = true;
    };
  };
in [ ./alacritty ./bat ./neovim ./starship ./tmux ./zsh more ]
