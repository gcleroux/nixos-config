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

    neovim-flake = {
      url = "github:gcleroux/neovim-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
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

      # deploy-rs's activation helpers, but with the deploy-rs package from nixpkgs:
      # it's in the binary cache and matches the `deploy` CLI in the dev shell.
      deployPkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        overlays = [
          inputs.deploy-rs.overlays.default
          (final: prev: {
            deploy-rs = {
              inherit (inputs.nixpkgs.legacyPackages.x86_64-linux) deploy-rs;
              inherit (prev.deploy-rs) lib;
            };
          })
        ];
      };
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

      nixosConfigurations = {
        ####################
        # Framework laptop #
        ####################
        nixos-fw = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs outputs;
            username = "guillaume";
            hostname = "nixos-fw";
          };
          modules = [
            ./hosts/nixos-fw

            inputs.disko.nixosModules.disko
          ];
        };

        #######################
        # Framework mainboard #
        #######################
        nixos-worker-01 = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs outputs;
            username = "guillaume";
            hostname = "nixos-worker-01";
          };
          modules = [
            ./hosts/nixos-worker-01
            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
          ];
        };

        ##########
        # Router #
        ##########
        calcifer = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs outputs;
            username = "guillaume";
            hostname = "calcifer";
          };
          modules = [
            ./hosts/calcifer
            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
          ];
        };

        #######
        # NAS #
        #######
        totoro = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs outputs;
            username = "guillaume";
            hostname = "totoro";
          };
          modules = [
            ./hosts/totoro
            inputs.disko.nixosModules.disko
          ];
        };
      };

      deploy.nodes = {
        calcifer = {
          hostname = "calcifer";
          sshUser = "guillaume";
          user = "root";
          magicRollback = true;
          confirmTimeout = 60;
          profiles.system.path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.calcifer;
        };
      };

      devShells = forAllSystems (
        system:
        import ./shell.nix {
          pkgs = inputs.nixpkgs.legacyPackages.${system};
        }
      );
    };
}
