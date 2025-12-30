{
  inputs,
  config,
  lib,
  pkgs,
  hostname,
  outputs,
  ...
}:
{
  services.lldap = {
    enable = true;
    settings = {
      ldap_base_dn = "dc=cleroux,dc=dev";
      ldap_port = 3890;
      http_port = 17170;
      database_url = "sqlite://./users.db?mode=rwc";

      ldap_user_email = "admin@cleroux.dev";
      ldap_user_dn = "admin";
      force_ldap_user_pass_reset = "always";
    };
    environment = {
      LLDAP_LDAP_USER_PASS_FILE = "%d/admin_pass";
    };
  };

  systemd.services.lldap.serviceConfig = {
    # Map root-owned files into systemd's per-service credentials dir
    LoadCredential = [
      "admin_pass:${config.sops.secrets."lldap/admin_pass".path}"
    ];
  };

  sops.secrets."lldap/admin_pass" = {
    sopsFile = ./lldap-admin-password;
    key = "data";
    mode = "0600";
  };
}
