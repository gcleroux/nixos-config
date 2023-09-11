{ pkgs, ... }: {
  # Cursor setup
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  # GTK theming
  gtk = {
    enable = true;

    cursorTheme.name = "Bibata-Modern-Ice";
    cursorTheme.package = pkgs.bibata-cursors;
    cursorTheme.size = 24;

    font.name = "DejaVu Sans";
    font.package = pkgs.dejavu_fonts;
    font.size = 12;

    iconTheme.name = "Papirus-Dark";
    iconTheme.package = pkgs.papirus-icon-theme;

    theme.name = "Nordic";
    theme.package = pkgs.nordic;
  };
}
