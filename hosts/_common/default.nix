# Configuration shared by every host
{
  inputs,
  outputs,
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
}
