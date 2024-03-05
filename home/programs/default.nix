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
  ./bottom
  ./chromium
  ./direnv
  ./foot
  ./fzf
  ./git
  ./lazygit
  ./mpv
  ./neovim
  ./nnn
  ./starship
  ./swaylock
  ./tmux
  ./waybar
  ./wofi
  ./zsh
  more
]
