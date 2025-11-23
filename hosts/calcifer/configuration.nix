{
  inputs,
  config,
  pkgs,
  username,
  hostname,
  outputs,
  ...
}:
let
  gatewayIP = "192.168.0.10";
  gatewayMask = 24;
in
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

  networking = {
    hostName = hostname;
    useDHCP = false;
    extraHosts = "${gatewayIP} ${hostname}";
    firewall.enable = true;

    bridges.br-lan.interfaces = [
      "enp2s0"
      "enp3s0"
      "enp4s0"
    ];

    interfaces = {
      enp1s0 = {
        # WAN
        useDHCP = true;
      };
      br-lan = {
        ipv4.addresses = [
          {
            address = gatewayIP;
            prefixLength = gatewayMask;
          }
        ];
      };
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
    };
    dnsmasq = {
      enable = true;
      settings = {
        domain-needed = true;
        localise-queries = true;
        stop-dns-rebind = true;
        cache-size = 1000;
        no-resolv = true;

        dhcp-range = [ "br-lan,192.168.0.100,192.168.0.250,12h" ];
        interface = "br-lan";

        local = "/internal/";
        domain = "internal";
        expand-hosts = true;
      };
    };
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
      clinfo
      foot
      git
      glib
      glxinfo
      iputils
      mesa
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
