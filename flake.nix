{
  description = "NixOS configuration";

  inputs = {
    # Which version of NixOS packages to use
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      # Which version of Home-manager to use
      url = "github:nix-community/home-manager";

      # We want to use the same set of nixpkgs as our system.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, ... }@inputs:
    let
      inherit (self) outputs;
      inherit (inputs.nixpkgs) lib;

      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forAllSystems = inputs.nixpkgs.lib.genAttrs systems;
    in
    {
      overlays = import ./overlays { inherit inputs; };
      # packages = forAllSystems (system: import ./pkgs inputs.nixpkgs.legacyPackages.${system});
      packages = forAllSystems (
        system:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
        in
        lib.packagesFromDirectoryRecursive {
          callPackage = lib.callPackageWith pkgs;
          directory = ./pkgs;
        }
      );
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      # Standalone NixOS conf
      nixosConfigurations.nixos-fw = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;

          username = "guillaume";
          hostname = "nixos-fw";
        };
        modules = [
          ./hosts/nixos-fw
        ];
      };

      homeConfigurations."guillaume@nixos-fw" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          inherit inputs outputs;
          inherit (self) packages;
        };
        modules = [
          inputs.sops-nix.homeManagerModules.sops
          ./home/guillaume.nix
        ];
      };
      devShells = forAllSystems (
        system:
        import ./shell.nix {
          pkgs = inputs.nixpkgs.legacyPackages.${system};
        }
      );
    };
}
