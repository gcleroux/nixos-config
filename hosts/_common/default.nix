# Configuration shared by every host
{
  inputs,
  lib,
  hostname,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager
    ../../modules/nixos/services
    ../../users
  ];

  # Each user's config comes from users/<name>/home/, see users/default.nix
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    sharedModules = [
      inputs.sops-nix.homeManagerModules.sops
      # Neovim lives in its own flake: plugins, config and tooling in one package
      inputs.neovim-flake.homeModules.default
    ];
    extraSpecialArgs = {
      inherit inputs hostname;
    };
  };

  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
    config.allowUnfree = true;
    overlays = [ (import ../../overlays) ];
  };

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = lib.mkDefault 10;
    };
    efi.canTouchEfiVariables = true;
  };
  hardware.enableAllFirmware = true;
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  networking.hostName = hostname;

  # Key-only SSH. Root login is off unless a host opts in for deploy-rs.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = lib.mkDefault "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # The interactive shell. Login shells stay bash, which hands over to fish.
  programs.fish.enable = true;

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";
}
