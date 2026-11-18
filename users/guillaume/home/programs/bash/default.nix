{ pkgs, ... }:
{
  programs.bash = {
    enable = true;
    initExtra = ''
      # Parent isn't fish, not a nested shell, not `bash -c`
      if [[ $(< /proc/$PPID/comm) != fish && $SHLVL == [12] && -z ''${BASH_EXECUTION_STRING} ]]; then
        # Programs that start $SHELL (nix shell…) then open fish too
        SHELL=${pkgs.fish}/bin/fish exec ${pkgs.fish}/bin/fish
      fi
    '';
  };
}
