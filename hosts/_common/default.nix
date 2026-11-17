# Configuration shared by every host
{
  inputs,
  outputs,
  lib,
  hostname,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
  ]
  # Option modules (host.*); toggled per host.
  ++ builtins.attrValues outputs.nixosModules;

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

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";
}
