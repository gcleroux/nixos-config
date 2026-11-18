{ config, pkgs, ... }:
{
  imports = [
    ./programs/bat
    ./programs/bottom
    ./programs/fish
    ./programs/fzf
    ./programs/git
    ./programs/starship
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
  };

  programs.delta = {
    enable = true;
    options.navigate = true;
  };
  programs.eza.enable = true;
  programs.ripgrep.enable = true;
  # programs.zellij.enable = true;
  programs.zoxide.enable = true;

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

  # This will automatically import SSH keys as age keys
  sops.age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];

  # Installed packages
  home.packages = with pkgs; [
    dig
    fd
    inetutils
    jq
    killall
    traceroute
    yq-go
  ];
}
