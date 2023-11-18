{ config, ... }: {
  programs.git = {
    enable = true;
    aliases = {
      ignore = "update-index --skip-worktree";
      unignore = "update-index --no-skip-worktree";
      ignored = "!git ls-files -v | grep '^[[:lower:]]'";
    };
    extraConfig = {
      core = { whitespace = "trailing-space,space-before-tab"; };

      url = { "https://github.com/" = { insteadOf = [ "gh:" "github:" ]; }; };

    };
    userName = "Guillaume Cléroux";

    # This is kind of a hack, sops-nix uses complete files instead of values so
    # we link a secret formatted for git include
    includes = [{ inherit (config.sops.secrets.email) path; }];
  };

  sops.secrets.email = { };
}
