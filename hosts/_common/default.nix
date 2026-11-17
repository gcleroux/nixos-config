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

  networking.hostName = hostname;
}
