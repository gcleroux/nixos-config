{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.services.fonts;
in
with lib;
{
  options = {
    host.services.fonts = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Install system fonts";
      };
    };
  };

  config = mkIf cfg.enable {
    # Installing fonts
    fonts = {
      packages = with pkgs; [
        # Nerd fonts
        (nerdfonts.override {
          fonts = [
            "Cousine"
            "Hack"
            "FiraCode"
            "Noto"
          ];
        })

        # System fonts
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-emoji
        noto-fonts-extra
      ];
    };
  };
}
