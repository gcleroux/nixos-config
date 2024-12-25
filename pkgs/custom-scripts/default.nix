{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "custom-scripts";
  version = "0.1.0";

  src = ./scripts;
  phases = "installPhase";

  installPhase = ''
    mkdir -p $out/bin

    while IFS= read -r script; do
        cp ${src}/$script $out/bin/$script
        chmod +x $out/bin/$script
    done < <(ls -1 ${src})
  '';
}
