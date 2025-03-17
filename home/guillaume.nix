{
  config,
  pkgs,
  username,
  ...
}:
{
  imports =
    builtins.concatMap import [
      ./programs
      ./services
      ./themes
      ./wm
    ]
    ++ [ ./default-apps.nix ];

  # This will automatically import SSH keys as age keys
  sops.age.sshKeyPaths = [ "/home/guillaume/.ssh/sops-nix_ed25519" ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.sessionVariables = {
    BROWSER = "firefox";
    TERMINAL = "foot";

    # gnome-keyring needed env vars
    GNOME_KEYRING_CONTROL = "$XDG_RUNTIME_DIR/keyring";
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";
  };
  home.sessionPath = [ "$HOME/go/bin" ];

  # Installed packages
  home.packages = with pkgs; [
    age
    clipboard-jh
    dig
    fd
    fluxcd
    fusee-launcher
    gh
    go
    hey
    jq
    k9s
    killall
    kubectl
    kubelogin-oidc
    kubernetes-helm
    kubie
    kustomize
    libreoffice
    lswt
    moonlight-qt
    neofetch
    obs-studio
    pavucontrol
    qbittorrent
    rclone
    signal-desktop
    sops
    spotify-player
    thunderbird-bin
    vesktop
    wbg
    way-displays
    wlr-randr
    yq
    zathura
  ];

  # TODO: Find a place for this config
  # Creating default connection for virt-manager
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };

    # https://codeberg.org/river/wiki#workaround-for-firefox
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "";
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
}
