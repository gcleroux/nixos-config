{ pkgs, ... }: {
  programs.nnn = {
    enable = true;
    package = pkgs.nnn.override ({ withNerdIcons = true; });
    bookmarks = {
      d = "~/Downloads";
      p = "~/Projects";
      P = "~/Pinax/Git";
      s = "~/School";
    };
    plugins.mappings = {
      a = "autojump";
      c = "chksum";
      k = "kdeconnect";
      r = "renamer";
      R = "rsynccp";
    };
    plugins.src = (pkgs.fetchFromGitHub {
      owner = "jarun";
      repo = "nnn";
      rev = "v4.8";
      sha256 = "sha256-QbKW2wjhUNej3zoX18LdeUHqjNLYhEKyvPH2MXzp/iQ=";
    }) + "/plugins";

  };
}
