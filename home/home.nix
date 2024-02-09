{ config, pkgs, ... }@args:
let username = "guillaume";
in {
  # Applying custom overlays
  nixpkgs.overlays = import ./overlays args;

  imports =
    builtins.concatMap import [ ./programs ./services ./themes ./wm ./modules ];

  sops = {
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
  home.sessionVariables = {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";

    BROWSER = "vivaldi";
    TERMINAL = "alacritty";
  };

  # Installed packages
  home.packages = with pkgs; [
    bitwarden
    bitwarden-cli
    calibre
    caprine-bin
    gh
    gimp
    go
    hey
    httpie
    jq
    kalendar
    killall
    krita
    kubectl
    kubie
    libreoffice-qt
    moonlight-qt
    mullvad-vpn
    neofetch
    obs-studio
    pavucontrol
    qbittorrent
    rclone
    signal-desktop
    spotify-player
    swww
    thunderbird-bin
    trashy-zsh-fix
    vivaldi
    vlc
    webcord
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
