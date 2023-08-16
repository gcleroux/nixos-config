{
  description = "NixOS configuration";

  inputs = {
    # Which version of NixOS packages to use
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";

    home-manager = {
      # Which version of Home-manager to use
      url = "github:nix-community/home-manager/release-23.05";

      # We want to use the same set of nixpkgs as our system.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let inherit (import ./config.nix) user;
    in {
      nixosConfigurations.nixos-fw = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./hardware/nixos-fw.nix
          ./system/nixos-fw.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${user} = import ./users/${user}/home.nix;
          }
        ];
      };
    };
}
