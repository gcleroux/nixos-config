{ config, pkgs, ... }:
let username = "guillaume";
in {

  imports = builtins.concatMap import [ ./programs ./services ./themes ./wm ];

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    # This will automatically import SSH keys as age keys
    age.sshKeyPaths = [ "/home/guillaume/.ssh/id_ed25519" ];

    # TODO: Fix this uid to make it cleaner
    defaultSymlinkPath = "/run/user/1000/secrets";
    defaultSecretsMountPoint = "/run/user/1000/secrets.d";
  };

  nixpkgs.config = {
    # Disable if you don't want unfree packages
    allowUnfree = true;

    # Workaround for https://github.com/nix-community/home-manager/issues/2942
    allowUnfreePredicate = _: true;
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";

  # Installed packages
  home.packages = with pkgs; [
    bitwarden
    bitwarden-cli
    btop
    bottom
    caprine-bin
    chromium
    firefox
    gh
    gimp
    go
    hey
    httpie
    kalendar
    killall
    krita
    lazygit
    libreoffice-qt
    moonlight-qt
    mullvad-vpn
    neofetch
    obs-studio
    pavucontrol
    qbittorrent
    ripgrep
    signal-desktop
    spotify
    swww
    thunderbird-bin
    vlc
    zathura
  ];

  # TODO: Find a place for this config
  # Creating default connection for virt-manager
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  xdg = {
    enable = true;
    configFile."mimeapps.list".force = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        # DE apps
        "application/pdf" = [ "org.pwmt.zathura.desktop" ];
        "inode/directory" = [ "thunar.desktop" ];
        "image/*" = [ "imv.desktop" ];

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
