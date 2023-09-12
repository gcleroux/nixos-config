{ pkgs, ... }: {

  programs.bat.enable = true;

  programs.bat.config = {
    pager = "less -FR";
    theme = "Nord";
  };

  programs.bat.extraPackages = with pkgs; [
    delta
    entr

    bat-extras.batdiff
    bat-extras.batman
    bat-extras.batgrep
    bat-extras.batwatch
  ];
}
