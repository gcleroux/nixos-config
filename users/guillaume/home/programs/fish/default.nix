{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Disable greeting
      set fish_greeting
    '';
    shellAbbrs = {
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "......" = "cd ../../../../..";

      # Bat aliases
      bat = "bat -p";
      ban = "batman";
      biff = "batdiff";
      brep = "batgrep";

      f = "yazi";
      v = "nvim";

      nnn = "nnn -deo";

      gc = "git clone";
      gs = "git status";

      nixconf = "cd /etc/nixos";
      ns = "nix-shell -p";
      search = "nix search nixpkgs";
    };
  };
}
