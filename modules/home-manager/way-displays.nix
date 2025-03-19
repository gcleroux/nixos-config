{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.way-displays;

  # way-displays cfg.yaml options
  ###############################
  # ARRANGE
  # ALIGN
  # ORDER
  # SCALING
  # AUTO_SCALE
  # AUTO_SCALE_MIN
  # AUTO_SCALE_MAX
  # SCALE
  # MODE
  # TRANSFORM
  # VRR_OFF
  # LAPTOP_DISPLAY_PREFIX
  # MAX_PREFERRED_REFRESH (Deprecated)
  # DISABLED
  # CALLBACK_CMD
  # LOG_TRESHOLD

in
{

  options.services.way-displays = {
    enable = mkEnableOption "way-displays: Auto Manage Your Wayland Displays";

    package = mkOption {
      type = types.package;
      default = pkgs.way-displays;
      defaultText = literalExpression "pkgs.way-displays";
      description = ''
        way-displays derivation to use.
      '';
    };

    systemdTarget = mkOption {
      type = types.str;
      default = config.wayland.systemd.target;
      defaultText = literalExpression "config.wayland.systemd.target";
      description = ''
        Systemd target to bind to.
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        (lib.hm.assertions.assertPlatform "services.way-displays" pkgs lib.platforms.linux)
      ];
    }

    {
      home.packages = [ cfg.package ];

      # xdg.configFile."way-displays/cfg.yaml" =
      #   let
      #     generatedConfigStr =
      #       if cfg.profiles == { } && cfg.extraConfig == "" then directivesStr else oldDirectivesStr;
      #   in
      #   mkIf (generatedConfigStr != "") { text = generatedConfigStr; };

      systemd.user.services.way-displays = {
        Unit = {
          Description = "Auto Manages Your Wayland Displays";
          Documentation = "https://github.com/alex-courtis/way-displays";
          PartOf = cfg.systemdTarget;
          After = cfg.systemdTarget;
        };

        Service = {
          Type = "simple";
          NonBlocking = "true";
          ExecStart = "${cfg.package}/bin/way-displays --log-threshold debug";
          Restart = "always";
        };

        Install = {
          WantedBy = [ cfg.systemdTarget ];
        };
      };
    }
  ]);
}
