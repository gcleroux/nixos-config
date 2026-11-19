{
  programs.gh = {
    enable = true;
    # git keeps its own GitHub login (credential settings in programs/git)
    gitCredentialHelper.enable = false;
    settings.aliases.co = "pr checkout";
  };
}
