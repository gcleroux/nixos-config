let
  more = _: {
    programs.exa = {
      enable = true;
      enableAliases = true;
    };
  };
in [ ./alacritty ./bat ./neovim ./starship ./swaylock ./tmux ./zsh more ]
