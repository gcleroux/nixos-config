{ pkgs, ... }: {
  programs.nnn = {
    enable = true;
    package = pkgs.nnn.override { withNerdIcons = true; };
    extraPackages = with pkgs; [
      autojump
      libsForQt5.kdeconnect-kde
      renameutils
      rsync
      xdragon
    ];
    bookmarks = {
      d = "~/Downloads";
      p = "~/Projects";
      P = "~/Pinax/Git";
      s = "~/School";
    };
    plugins.mappings = {
      j = "autojump";
      d = "dragdrop";
      c = "chksum";
      k = "kdeconnect";
      r = "renamer";
      R = "rsynccp";
      n = "nmount";
    };
    plugins.src = pkgs.nnn.src + "/plugins";
  };
}
