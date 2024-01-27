{ config, ... }: {
  programs.git = {
    enable = true;
    aliases = {
      ignore = "update-index --skip-worktree";
      unignore = "update-index --no-skip-worktree";
      ignored = "!git ls-files -v | grep '^[[:lower:]]'";
    };
    extraConfig = {
      core = {
        editor = "nvim";
        whitespace = "trailing-space,space-before-tab";
      };
      credential = {
        "https://github.com" = { username = "gcleroux"; };
        "https://codeberg.org" = { username = "gcleroux"; };
        helper = "cache";
      };
      init = { defaultBranch = "main"; };
      remote.origin = { prune = true; };

      url = {
        "https://github.com/" = { insteadOf = [ "gh:" "github:" ]; };
        "https://codeberg.org/" = { insteadOf = [ "cb:" "codeberg:" ]; };
      };

    };
    userName = "Guillaume Cléroux";
    userEmail = builtins.readFile "${config.sops.secrets.github_email.path}";
  };

  sops.secrets.github_email.sopsFile = ./secrets.yaml;
}
