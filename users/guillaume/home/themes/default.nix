{ pkgs, config, ... }:
{
  # Cursor setup; gtk.enable also sets it as GTK's cursor theme
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  # GTK theming
  gtk = {
    enable = true;
    gtk4.theme = config.gtk.theme;

    font.name = "DejaVu Sans";
    font.package = pkgs.dejavu_fonts;
    font.size = 12;

    iconTheme.name = "Papirus-Dark";
    iconTheme.package = pkgs.papirus-icon-theme;

    theme.name = "Nordic";
    theme.package = pkgs.nordic;
  };
}
