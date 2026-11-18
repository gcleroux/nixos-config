{ pkgs, ... }:
{
  imports = [
    ./programs/ai
    ./programs/direnv
    ./programs/kubernetes
    ./programs/lazygit
    ./programs/neovim
    ./programs/ssh
    ./programs/yazi
  ];

  home.sessionPath = [ "$HOME/go/bin" ];

  home.packages = with pkgs; [
    age
    fusee-nano
    gh
    gnumake
    go
    hey
    rclone
    sops
  ];
}
