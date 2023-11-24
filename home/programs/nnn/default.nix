{ pkgs, ... }: {
  programs.nnn = {
    enable = true;
    package = pkgs.nnn.override { withNerdIcons = true; };
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
    plugins.src = pkgs.nnn.src + "/plugins";
  };
}
