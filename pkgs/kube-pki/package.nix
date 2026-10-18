{
  lib,
  writeShellApplication,
  coreutils,
  diffutils,
  getent,
  gnugrep,
  gnused,
  jq,
  openssl,
  util-linux,
}:

writeShellApplication {
  name = "kube-pki";

  runtimeInputs = [
    coreutils
    diffutils
    getent
    gnugrep
    gnused
    jq
    openssl
    util-linux
  ];

  text = builtins.readFile ./kube-pki.sh;

  meta = {
    description = "Declarative, openssl-based PKI for the NixOS kubernetes module";
    mainProgram = "kube-pki";
    platforms = lib.platforms.linux;
  };
}
