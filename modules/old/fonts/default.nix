{ config, pkgs, ... }:
{
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
}
