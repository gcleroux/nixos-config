let
  more = _: {
    programs.eza = {
      enable = true;
      enableAliases = true;
    };
    programs.imv.enable = true;
    programs.ripgrep.enable = true;
  };
in [
  ./alacritty
  ./bat
  # ./chromium
  ./direnv
  ./git
  ./mpv
  ./ncmpcpp
  ./neovim
  ./nnn
  ./starship
  ./swaylock
  ./tmux
  ./waybar
  ./zsh
  more
]
