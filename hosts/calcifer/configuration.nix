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
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      outputs.overlays.default
    ];
  };
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings = {
      # Nix package manager options
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        username
      ];
    };
  };

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

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

  # Enable the OpenSSH daemon.
  services = {
    openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
      openFirewall = false;
    };
    resolved.enable = false;
  };

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
      dnsutils
      foot
      git
      iputils
      neovim
      pciutils
      powerstat
      traceroute
      usbutils
      wget
    ];
  };

  system.stateVersion = "25.05";
}
