{ hostname, ... }:
{
  wrappers.neovim = {
    enable = true;

    # Which flake nixd should evaluate for option completion is per machine,
    # so it cannot live in the neovim flake.
    settings.nixd = {
      nixpkgs = ''import (builtins.getFlake "/etc/nixos").inputs.nixpkgs { }'';
      nixos = ''(builtins.getFlake "/etc/nixos").nixosConfigurations.${hostname}.options'';
      home_manager = ''(builtins.getFlake "/etc/nixos").nixosConfigurations.${hostname}.options.home-manager.users.type.getSubOptions [ ]'';
    };
  };
}
