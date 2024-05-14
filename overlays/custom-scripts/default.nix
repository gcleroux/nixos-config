{
  pkgs,
  config,
  lib,
  ...
}:
(self: super: {
  custom-scripts = super.stdenv.mkDerivation rec {
    pname = "custom-scripts";
    version = "0.1.0-dev";

    src = ./scripts;
    phases = "installPhase";

    # buildInputs = with pkgs; [
    #   bash
    #   brightnessctl
    #   coreutils
    #   ddcutil
    #   libnotify
    #   networkmanager
    #   wireplumber
    #   wl-clipboard
    #   wofi
    # ];
    # nativeBuildInputs = [ pkgs.makeWrapper ];

    # wrapProgram $out/bin/$script \
    # --prefix PATH : ${lib.makeBinPath buildInputs}

    installPhase = ''
      mkdir -p $out/bin

      while IFS= read -r script; do
          cp ${src}/$script $out/bin/$script
          chmod +x $out/bin/$script
      done < <(ls -1 ${src})
    '';
  };
})
