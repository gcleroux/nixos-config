{
  inputs,
  outputs,
  username,
  hostname,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    sharedModules = [
      inputs.sops-nix.homeManagerModules.sops
    ];
    extraSpecialArgs = {
      inherit
        inputs
        outputs
        username
        hostname
        ;
    };

    users.${username} = {
      imports = [
        ../../users/guillaume/home
        ../../users/guillaume/home/dev.nix
        ../../users/guillaume/home/desktop.nix
      ];
    };
  };
}
