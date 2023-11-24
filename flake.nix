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

    hyprland.url = "github:hyprwm/Hyprland";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
  };

  outputs = { self, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in {
      # Standalone NixOS conf
      nixosConfigurations = {
        inherit system;
        nixos-fw = inputs.nixpkgs.lib.nixosSystem {
          modules = [ ./hardware/nixos-fw.nix ./system/nixos-fw.nix ];
        };
      };
      homeConfigurations = {
        "guillaume@nixos-fw" =
          inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              inputs.hyprland.homeManagerModules.default
              inputs.sops-nix.homeManagerModules.sops
              ./home/home.nix
            ];
          };
      };
      devShells.${system}.default =
        pkgs.mkShell { packages = with pkgs; [ age ssh-to-age sops ]; };
    };
}
