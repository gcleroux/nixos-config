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

  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      user = "guillaume";
      system = "x86_64-linux";
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        nixos-fw = lib.nixosSystem {
          inherit system;

          modules = [
            ./system/fw-laptop.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${user} = import ./users/${user}/home.nix;
            }
          ];
        };
      };
    };
}

