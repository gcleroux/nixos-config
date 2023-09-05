{ pkgs, ... }:
let inherit (import ../../config.nix) user;
in {
  imports = [
    # Importing custom application configs
    ./alacritty.nix
    ./bat.nix
    ./exa.nix
    ./fusuma.nix
    ./neovim.nix
    ./starship.nix
    ./tmux.nix
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
    caprine-bin
    chromium
    discord
    firefox
    gh
    gimp
    git
    go
    krita
    lazygit
    libreoffice-qt
    moonlight-qt
    mullvad-vpn
    neofetch
    obs-studio
    qbittorrent
    ripgrep
    signal-desktop
    spotify
    teams
    thunderbird-bin
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

  xdg = {
    enable = true;
    configFile."mimeapps.list".force = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        # Archive tool
        "application/*tar" = [ "org.kde.ark.desktop" ];
        "application/7z" = [ "org.kde.ark.desktop" ];
        "application/rar" = [ "org.kde.ark.desktop" ];
        "application/zip" = [ "org.kde.ark.desktop" ];

        # DE apps
        "application/pdf" = [ "org.kde.okular.desktop" ];
        "inode/directory" = [ "org.kde.dolphin.desktop" ];
        "image/*" = [ "org.kde.gwenview.desktop" ];

        # Mail
        "message/rfc822" = [ "thunderbird.desktop" ];
        "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
        "x-scheme-handler/mid" = [ "thunderbird.desktop" ];

        # Multimedia
        "audio/*" = [ "vlc.desktop" ];
        "video/*" = [ "vlc.desktop" ];

        # Plain text editor
        "text/plain" = [ "nvim.desktop" ];

        # Signal
        "x-scheme-handler/sgnl" = [ "signal-desktop.desktop" ];
        "x-scheme-handler/signalcaptcha" = [ "signal-desktop.desktop" ];

        # Web browser
        "application/x-extension-htm" = [ "chromium-browser.desktop" ];
        "application/x-extension-html" = [ "chromium-browser.desktop" ];
        "application/x-extension-shtml" = [ "chromium-browser.desktop" ];
        "application/x-extension-xht" = [ "chromium-browser.desktop" ];
        "application/x-extension-xhtml" = [ "chromium-browser.desktop" ];
        "application/xhtml+xml" = [ "chromium-browser.desktop" ];
        "text/html" = [ "chromium-browser.desktop" ];
        "x-scheme-handler/about" = [ "chromium-browser.desktop" ];
        "x-scheme-handler/chrome" = [ "chromium-browser.desktop" ];
        "x-scheme-handler/ftp" = [ "chromium-browser.desktop" ];
        "x-scheme-handler/http" = [ "chromium-browser.desktop" ];
        "x-scheme-handler/https" = [ "chromium-browser.desktop" ];
        "x-scheme-handler/unknown" = [ "chromium-browser.desktop" ];
      };
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
