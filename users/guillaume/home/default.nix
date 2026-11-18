{
  pkgs,
  username,
  ...
}:
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

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = username;
  home.homeDirectory = "/home/${username}";

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
