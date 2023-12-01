{ pkgs, config, lib, ... }:
# Add back wayland flags to signal if NIXOS_
(self: super: {
  signal-desktop = super.signal-desktop.overrideAttrs (old: {
    preFixup = old.preFixup + ''
      gappsWrapperArgs+=(
        --add-flags "--enable-features=UseOzonePlatform"
        --add-flags "--ozone-platform=wayland"
      )
    '';
  });
})
