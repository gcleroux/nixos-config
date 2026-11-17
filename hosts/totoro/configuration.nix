{
  inputs,
  config,
  pkgs,
  username,
  hostname,
  outputs,
  ...
}:
{
  # deploy-rs copies unsigned store paths to this host as the ssh user
  nix.settings.trusted-users = [
    "root"
    username
  ];

  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
    ];
    createHome = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICS77iyKWFPGfozY/N0daz6d9uEXhpdSVpsTTIkBbcRg guillaume@nixos-fw"
    ];
  };

  # deploy-rs logs in as root: key only, from the LAN or nixos-fw's VPN address
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  users.users.root.openssh.authorizedKeys.keys = [
    ''from="10.0.0.0/24,2606:6d00:ffb:6600::/64,10.0.9.101,2606:6d00:ffb:6609::101" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICS77iyKWFPGfozY/N0daz6d9uEXhpdSVpsTTIkBbcRg guillaume@nixos-fw''
  ];

  # Enable passwordless config
  security = {
    sudo.enable = true;
    pam = {
      sshAgentAuth.enable = true;
      services.sudo.sshAgentAuth = true;
    };
  };

  programs = {
    fish.enable = true;
    zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
    };
  };

  environment = {
    # Installed packages
    systemPackages = with pkgs; [
      bottom
      btrbk
      foot
      git
      gptfdisk
      iputils
      neovim
      pciutils
      powerstat
      usbutils
      wget
    ];
  };

  system.stateVersion = "25.11";
}
