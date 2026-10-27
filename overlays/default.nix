{ inputs, ... }:
let
  # This one brings our custom packages from the 'pkgs' directory
  additions =
    final: prev:
    (prev.lib.packagesFromDirectoryRecursive {
      callPackage = prev.lib.callPackageWith final;
      directory = ../pkgs;
    });

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    # fnott segfaults in wl_pointer_motion when hovering a notification
    # whose output was cleared by surface_leave() (multi-monitor, mixed scale).
    fnott = prev.fnott.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or [ ]) ++ [ ./patches/fnott-pointer-motion-null-monitor.patch ];
    });
  };
in
{
  default = final: prev: (additions final prev) // (modifications final prev);
}
