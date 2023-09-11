{ pkgs, ... }: {
  # Cursor setup
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 32;
  };

  # GTK theming
  gtk = {
    iconTheme.name = "Papirus-Dark";
    iconTheme.package = pkgs.papirus-icon-theme;

    theme.name = "Nordic";
    theme.package = pkgs.nordic;
  };
}
