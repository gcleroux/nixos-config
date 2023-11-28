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
  ./chromium
  ./direnv
  ./git
  ./mpv
  ./neovim
  ./nnn
  ./starship
  ./swaylock
  ./tmux
  ./waybar
  ./zsh
  more
]
