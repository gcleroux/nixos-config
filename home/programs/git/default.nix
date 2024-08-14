{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;
    delta = {
      enable = true;
      options.navigate = true;
    };
    aliases = {
      ignore = "update-index --skip-worktree";
      unignore = "update-index --no-skip-worktree";
      ignored = "!git ls-files -v | grep '^[[:lower:]]'";
    };
    userName = "Guillaume Cléroux";
    userEmail = "73357644+gcleroux@users.noreply.github.com";

    extraConfig = {
      core = {
        editor = "nvim";
        whitespace = "trailing-space,space-before-tab";
      };
      credential = {
        "https://github.com" = {
          username = "gcleroux";
        };
        "https://codeberg.org" = {
          username = "gcleroux";
        };
        helper = "cache";
      };
      init = {
        defaultBranch = "main";
      };
      merge = {
        conflictstyle = "diff3";
      };
      diff = {
        colorMoved = "default";
      };
      remote.origin = {
        prune = true;
      };

      url = {
        "https://github.com/" = {
          insteadOf = [
            "gh:"
            "github:"
          ];
        };
        "https://codeberg.org/" = {
          insteadOf = [
            "cb:"
            "codeberg:"
          ];
        };
      };
    };
  };
}
