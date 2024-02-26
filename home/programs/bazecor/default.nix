{ config, pkgs, ... }: {
  home.packages = [ pkgs.unstable.bazecor ];
  xdg.desktopEntries.Bazecor = {
    name = "Bazecor";
    exec =
      "bazecor --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-features=WaylandWindowDecorations --ozone-platform=wayland";
  };
}
