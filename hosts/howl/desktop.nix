{ pkgs, ... }:
{
  xdg.portal = {
    enable = true;
    wlr = {
      enable = true;
      settings = {
        screencast = {
          max_fps = 30;
          chooser_type = "simple";
          chooser_cmd = "${pkgs.slurp}/bin/slurp -f 'Monitor: %o' -or";
        };
      };
    };
    config.common = {
      default = [
        "wlr"
        "gtk"
      ];
      "org.freedesktop.impl.portal.Inhibit" = [ "none" ];
    };
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  programs = {
    river-classic.enable = true;
    # Runs river as a systemd service: logging out stops graphical-session.target and its services
    uwsm = {
      enable = true;
      waylandCompositors.river = {
        prettyName = "River";
        binPath = "/run/current-system/sw/bin/river";
      };
    };
    thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
  };

  services = {
    dbus.implementation = "broker";
    # Thunar services
    gvfs.enable = true; # Mount, trash, and other functionalities
    tumbler.enable = true; # Thumbnail support for images
    upower.enable = true;
    libinput.enable = true;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.cousine
    nerd-fonts.hack
    nerd-fonts.fira-code
    nerd-fonts.noto

    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
  ];
}
