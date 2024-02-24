{ inputs, ... }:
(self: super: {
  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable = import inputs.nixpkgs-unstable {
    inherit (self) system;
    config.allowUnfree = true;
  };
})
