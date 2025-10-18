{ pkgs, ... }:
{
  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
      theme = "Nord";
    };
    extraPackages = with pkgs; [
      delta
      entr

      bat-extras.batdiff
      bat-extras.batman
      bat-extras.batgrep
      bat-extras.batwatch
    ];
  };
}
