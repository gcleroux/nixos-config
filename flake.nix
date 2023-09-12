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
  };

  outputs = { nixpkgs, home-manager, hyprland, ... }:
    let inherit (import ./config.nix) user;
    in {
      # Standalone NixOS conf
      nixosConfigurations = {
        nixos-fw = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hardware/nixos-fw.nix ./system/nixos-fw.nix ];
        };
      };

      homeConfigurations = {
        "${user}@nixos-fw" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules =
            [ hyprland.homeManagerModules.default ./users/${user}/home.nix ];
        };
      };

    };
}
