{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.user.programs.ai;
in
with lib;
{
  options = {
    user.programs.ai = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables AI coding agents";
      };

      claude-code = {
        enable = mkOption {
          default = true;
          type = with types; bool;
          description = "Installs Anthropic's claude-code CLI";
        };

        package = mkOption {
          default = pkgs.claude-code;
          defaultText = literalExpression "pkgs.claude-code";
          type = with types; package;
          description = "The claude-code package to install";
        };
      };

      codex = {
        enable = mkOption {
          default = true;
          type = with types; bool;
          description = "Installs OpenAI's codex CLI";
        };

        package = mkOption {
          default = pkgs.codex;
          defaultText = literalExpression "pkgs.codex";
          type = with types; package;
          description = "The codex package to install";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      optional cfg.claude-code.enable cfg.claude-code.package
      ++ optional cfg.codex.enable cfg.codex.package;
  };
}
