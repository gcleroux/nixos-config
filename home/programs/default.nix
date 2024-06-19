let
  more = _: {
    programs.eza.enable = true;
    programs.imv.enable = true;
    programs.ripgrep.enable = true;
  };
in
[
  ./alacritty
  ./bat
  ./bottom
  ./chromium
  ./direnv
  ./fish
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
