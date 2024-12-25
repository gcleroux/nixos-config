# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#custom-scripts'
pkgs: {
  # example = pkgs.callPackage ./example { };
  custom-scripts = pkgs.callPackage ./custom-scripts { };
}
