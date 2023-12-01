let
  more = _: {
    programs.eza = {
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
