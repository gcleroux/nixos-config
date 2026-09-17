{
  inputs,
  outputs,
  username,
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
      inherit inputs outputs username;
    };

    users.${username} = {
      imports = [
        ../../home/users/guillaume.nix
        ../../home/profiles/desktop.nix
      ];

      user.programs.ai.enable = true;
    };
  };
}
