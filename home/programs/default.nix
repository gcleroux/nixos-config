let
  more = _: {
    programs.eza.enable = true;
    programs.imv.enable = true;
    programs.ripgrep.enable = true;
    programs.yazi.enable = true;
    # programs.zellij.enable = true;
    programs.zoxide.enable = true;
  };
in
[
  ./aerc
  ./alacritty
  ./bat
  ./bottom
  # ./chromium
  ./direnv
  ./firefox
  ./fish
  ./foot
  ./fzf
  ./git
  ./lazygit
  ./mpv
  ./neovim
  ./nnn
  ./spotify-player
  ./ssh
  ./starship
  ./swaylock
  ./tmux
  ./waybar
  ./wofi
  ./zsh
  more
]
