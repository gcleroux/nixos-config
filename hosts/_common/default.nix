# Configuration shared by every host
{
  inputs,
  pkgs,
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
    sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
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

  # Basic admin tools for every account, root included
  environment.systemPackages = with pkgs; [
    bottom
    foot.terminfo
    git
    neovim
    pciutils
    powerstat
    usbutils
    wget
  ];

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
