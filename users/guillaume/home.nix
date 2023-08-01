{ config, pkgs, ... }:

{
  imports = [
    ../../modules/starship.nix
    ../../modules/zsh.nix
    ../../modules/neovim.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "guillaume";
  home.homeDirectory = "/home/guillaume";

  # Installed packages
  home.packages = with pkgs; [
    auto-cpufreq
    autojump
    bat
    bitwarden
    bitwarden-cli
    btop
    cargo
    clinfo
    coreutils
    exa
    firefox
    gcc
    gdb
    gh
    gimp
    git
    glxinfo
    go
    imagemagick
    kitty
    krita
    lazygit
    libreoffice-qt
    libsForQt5.kdeconnect-kde
    luajitPackages.luarocks
    mesa
    moonlight-qt
    mullvad-vpn
    neofetch
    nixfmt
    nodePackages.npm
    nodejs-slim_20
    obs-studio
    obsidian
    openconnect
    openvpn
    parsec-bin
    pciutils
    pipewire
    powerstat
    python311
    python311Packages.pip
    qbittorrent
    ripgrep
    rtkit
    signal-desktop
    spotify
    starship
    teams
    teamviewer
    thunderbird-bin
    timeshift
    usbutils
    ungoogled-chromium
    unzip
    vlc
    webcord
    wget
    wl-clipboard
    wlr-randr
    xorg.xeyes
  ];

  # Session variables
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  services.gpg-agent = {                          
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
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
