# Kubernetes certificates for this host, issued by host.services.kubernetes-pki
# from the CA in ./pki (see docs/kubernetes-pki.md for the one-time bootstrap).
#
#   pki/ca.pem                   public CA certificate (plain text)
#   pki/ca-key.pem               CA private key (sops)
#   pki/service-account-key.pem  service-account token signing key (sops)
#   pki/admin.kubeconfig         long-lived admin kubeconfig for workstations (sops)
{ config, lib, ... }:
let
  pki = ./pki;
  bootstrapped =
    builtins.pathExists (pki + "/ca.pem")
    && builtins.pathExists (pki + "/ca-key.pem")
    && builtins.pathExists (pki + "/service-account-key.pem");
in
{
  host.services.kubernetes-pki = {
    enable = true;
    caCertFile = lib.mkIf bootstrapped (pki + "/ca.pem");
    caKeyFile = lib.mkIf bootstrapped config.sops.secrets."kubernetes/ca-key.pem".path;
    serviceAccountKeyFile =
      lib.mkIf bootstrapped
        config.sops.secrets."kubernetes/service-account-key.pem".path;
  };

  sops.secrets = lib.mkIf bootstrapped {
    "kubernetes/ca-key.pem" = {
      sopsFile = pki + "/ca-key.pem";
      format = "binary";
    };
    "kubernetes/service-account-key.pem" = {
      sopsFile = pki + "/service-account-key.pem";
      format = "binary";
    };
  };
}
