{
  programs.chromium = {
    enable = true;
    commandLineArgs =
      [ "--enable-features=TouchpadOverscrollHistoryNavigation" ];
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
      { id = "bmnlcjabgnpnenekpadlanbbkooimhnj"; } # honey
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # bitwarden
      { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # sponsorblock
    ];
  };
}
