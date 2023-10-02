let
  more = _: {
    programs.exa = {
      enable = true;
      enableAliases = true;
    };
  };
in [
  ./alacritty
  ./bat
  ./direnv
  ./neovim
  ./starship
  ./swaylock
  ./tmux
  ./waybar
  ./zsh
  more
]
