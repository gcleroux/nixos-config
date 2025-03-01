{
  programs.chromium = {
    enable = true;
    commandLineArgs = [ "--enable-features=TouchpadOverscrollHistoryNavigation,OverlayScrollbar" ];
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # bitwarden
      { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # sponsorblock
    ];
  };
}
