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
    let
      # TODO: These values should be used in the system configuration
      host = "nixos-fw";
      user = "guillaume";
      system = "x86_64-linux";
    in {
      nixosConfigurations = {
        ${host} = nixpkgs.lib.nixosSystem {
          inherit system;

          modules = [
            ./hardware/${host}.nix
            ./system/${host}.nix
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
