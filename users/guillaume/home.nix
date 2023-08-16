{ pkgs, ... }:
let inherit (import ../../const.nix) user;
in {
  imports = [
    # Importing custom application configs
    ./bat.nix
    ./exa.nix
    ./fusuma.nix
    ./neovim.nix
    ./starship.nix
    ./zsh.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "${user}";
  home.homeDirectory = "/home/${user}";

  # Installed packages
  home.packages = with pkgs; [
    bitwarden
    bitwarden-cli
    btop
    discord
    firefox
    gh
    gimp
    git
    go
    kitty
    krita
    lazygit
    libreoffice-qt
    moonlight-qt
    mullvad-vpn
    neofetch
    obs-studio
    obsidian
    parsec-bin
    qbittorrent
    ripgrep
    signal-desktop
    spotify
    teams
    teamviewer
    thunderbird-bin
    ungoogled-chromium
    vlc
    zathura
  ];

  services = {
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
