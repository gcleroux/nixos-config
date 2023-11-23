{ pinnedChromium, ... }: {
  programs.chromium = {
    enable = true;
    package = pinnedChromium.chromium;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
      { id = "bmnlcjabgnpnenekpadlanbbkooimhnj"; } # honey
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # bitwarden
      { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } # sponsorblock
    ];
  };
}
