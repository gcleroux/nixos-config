{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
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
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = inputs.nixpkgs.lib.genAttrs systems;

      # Every host, configured from hosts/<name>. `deploy` overrides its deploy-rs node.
      hosts = {
        # Framework laptop
        nixos-fw = {
          deploy = {
            hostname = "localhost";
            # No root login on the laptop: deploy as guillaume, sudo asks for the password
            sshUser = "guillaume";
            interactiveSudo = true;
          };
        };

        # Framework mainboard
        nixos-worker-01 = { };

        # Router
        calcifer = {
          deploy.confirmTimeout = 60;
        };

        # NAS
        totoro = { };
      };

      mkHost =
        hostname: _:
        inputs.nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs hostname;
            inventory = import ./hosts/inventory.nix;
          };
          modules = [
            ./hosts/_common
            ./hosts/${hostname}
          ];
        };

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
      formatter = forAllSystems (system: inputs.nixpkgs.legacyPackages.${system}.nixfmt-tree);

      # `nix flake check`: deploy-rs's checks (they build every host), lint and formatting
      checks.x86_64-linux =
        let
          pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
          lint =
            name: command:
            pkgs.runCommand name { } ''
              cd ${self}
              ${command}
              touch $out
            '';
        in
        deployPkgs.deploy-rs.lib.deployChecks self.deploy
        // {
          deadnix = lint "deadnix" "${pkgs.deadnix}/bin/deadnix --fail --no-lambda-arg .";
          statix = lint "statix" "${pkgs.statix}/bin/statix check .";
          formatting = lint "formatting" "${pkgs.nixfmt}/bin/nixfmt --check $(find . -name '*.nix')";
        };

      nixosConfigurations = inputs.nixpkgs.lib.mapAttrs mkHost hosts;

      deploy = {
        sshUser = "root";
        user = "root";
        magicRollback = true;

        nodes = inputs.nixpkgs.lib.mapAttrs (
          hostname: host:
          {
            inherit hostname;
            profiles.system.path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations.${hostname};
          }
          // host.deploy or { }
        ) hosts;
      };

      devShells = forAllSystems (
        system:
        import ./shell.nix {
          pkgs = inputs.nixpkgs.legacyPackages.${system};
        }
      );
    };
}
