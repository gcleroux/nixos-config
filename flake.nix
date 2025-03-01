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

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, ... }@inputs:
    let
      inherit (self) outputs;

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

      packages = forAllSystems (
        system:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
        in
        inputs.nixpkgs.lib.packagesFromDirectoryRecursive {
          callPackage = inputs.nixpkgs.lib.callPackageWith pkgs;
          directory = ./pkgs;
        }
      );
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      ####################
      # Framework laptop #
      ####################
      nixosConfigurations.nixos-fw = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs outputs;
          username = "guillaume";
          hostname = "nixos-fw";
        };
        modules = [
          ./hosts/nixos-fw

          inputs.disko.nixosModules.disko
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              users.guillaume = import ./home/guillaume.nix;
              sharedModules = [
                inputs.sops-nix.homeManagerModules.sops
              ];
              extraSpecialArgs = {
                inherit inputs outputs;
                username = "guillaume";
              };
            };
          }
        ];
      };

      #######################
      # Framework mainboard #
      #######################
      nixosConfigurations.nixos-worker-01 = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs outputs;
          username = "guillaume";
          hostname = "nixos-worker-01";
        };
        modules = [
          ./hosts/nixos-worker-01
          inputs.disko.nixosModules.disko
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
