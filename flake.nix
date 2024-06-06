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
      username = "guillaume";
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in
    {
      # Standalone NixOS conf
      nixosConfigurations = {
        inherit system;
        nixos-fw = inputs.nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs username;
          };
          modules = [
            ./hardware/intel-framework.nix
            ./system/nixos-fw.nix
          ];
        };
      };
      homeConfigurations.${username} = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs username;
        };
        modules = [
          inputs.sops-nix.homeManagerModules.sops
          ./home/home.nix
        ];
      };
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          age
          ssh-to-age
          sops
        ];
      };
    };
}
