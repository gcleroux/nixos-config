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
  ./git
  ./neovim
  ./nnn
  ./starship
  ./swaylock
  ./tmux
  ./waybar
  ./zsh
  more
]
