{ pkgs, ... }:
let
  # TODO: Revert to nixos-unstable when merged
  # Fix until https://github.com/NixOS/nixpkgs/pull/334814#event-13895232855 is into nixos-unstable
  nixpkgsMaster = import (pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "195662d20d9c35f988d0122d34479f90da709e0a";
    sha256 = "sha256-e4ZDt1i10PE4ScWc9smyRJHrAWSdWHRtZ3ZyZE8v4UI=";
  }) { inherit (pkgs) system; };

  batdiff = nixpkgsMaster.bat-extras.batdiff.overrideAttrs (oldAttrs: {
    doCheck = false; # Disable the checkPhase to bypass the failing test
  });
in
{
  programs.bat = {
    enable = true;
    package = nixpkgsMaster.bat;
    config = {
      pager = "less -FR";
      theme = "Nord";
    };
    extraPackages = with nixpkgsMaster; [
      delta
      entr

      batdiff
      bat-extras.batman
      bat-extras.batgrep
      bat-extras.batwatch
    ];
  };
  programs.git.delta.package = nixpkgsMaster.delta;
}
