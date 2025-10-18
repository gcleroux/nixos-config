# Pinning a Package in Nix

When using nixos-unstable, some packages might be broken from
time to time. Nix makes it easy to use a specific package build
from the nixpkgs repository.

Nix fetchers will need a `sha256` hash to validate the repo.
There's two options to obtain this value for your patch:

1. Using an empty string (`""`) as the `sha256` value in your fetcher.

   Building the derivation will fail, but the expected hash will be displayed
   in the error output allowing you to replace the empty string with the
   correct value.

2. Using `nix flake prefetch` to download the flake ahead of time.

   ```bash
   #nix flake prefetch github:<owner><repo>/<rev>
   nix flake prefetch github:NixOS/nixpkgs/195662d20d9c35f988d0122d34479f90da709e0a --json | jq .hash
   ```

## Example

Let's say the delta package upstream is failing to build, and a fix has
been merged but isn't part of nixos-unstable yet. You can use said fix
by targeting the specific rev of the nixpkgs repo.

```nix
{ pkgs, ... }:
let
  # Fix until https://github.com/NixOS/nixpkgs/pull/334814#event-13895232855 is into nixos-unstable
  # Tracking PR status: https://nixpkgs-tracker.ocfox.me/?pr=334814
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
```
