{
  config,
  pkgs,
  ...
}:
{
  # How do I add the ./default-apps.nix to the imports?
  imports =
    builtins.concatMap import [
      ./programs
      ./services
      ./themes
      ./wm
    ]
    ++ [ ./default-apps.nix ];

  sops = {
    # This will automatically import SSH keys as age keys
    age.sshKeyPaths = [ "/home/guillaume/.ssh/id_ed25519" ];
    # TODO: Fix this uid to make it cleaner
    defaultSymlinkPath = "/run/user/1000/secrets";
    defaultSecretsMountPoint = "/run/user/1000/secrets.d";
  };
  # Generate secrets at activation time
  home.activation.setupEtc = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    /run/current-system/sw/bin/systemctl start --user sops-nix
  '';

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "guillaume";
  home.homeDirectory = "/home/guillaume";
  home.sessionVariables = {
    BROWSER = "chromium-browser";
    TERMINAL = "foot";

    CLIPBOARD_NOAUDIO = "1";
    CLIPBOARD_NOGUI = "1";
  };
  home.sessionPath = [ "$HOME/go/bin" ];

  # Installed packages
  home.packages = with pkgs; [
    age
    clipboard-jh
    deploy-rs
    dig
    fd
    fluxcd
    fusee-launcher
    gh
    gimp
    go
    hey
    jq
    k9s
    kalendar
    killall
    krita
    kubectl
    kubelogin-oidc
    kubernetes-helm
    kubie
    kustomize
    libreoffice
    lswt
    moonlight-qt
    mullvad-vpn
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
}
