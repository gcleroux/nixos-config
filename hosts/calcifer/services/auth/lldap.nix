{
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.lldap.settings;
in
{
  services.lldap = {
    enable = true;
    settings = {
      ldap_base_dn = "dc=cleroux,dc=dev";
      ldap_host = "127.0.0.1";
      ldap_port = 3890;
      http_port = 17170;
      http_url = "https://lldap.home.cleroux.dev";
      database_url = "sqlite://./users.db?mode=rwc";
      # The key comes from key_seed instead, see LLDAP_KEY_SEED_FILE
      key_file = "";

      ldap_user_email = "admin@cleroux.dev";
      ldap_user_dn = "admin";
      force_ldap_user_pass_reset = "always";
    };
    environment = {
      LLDAP_LDAP_USER_PASS_FILE = "%d/admin_pass";
      # Derives the password hashing key, so users.db can be restored with the
      # repo alone. Changing it invalidates every password.
      LLDAP_KEY_SEED_FILE = "%d/key_seed";
    };
  };

  systemd.services.lldap.serviceConfig = {
    # Map root-owned files into systemd's per-service credentials dir
    LoadCredential = [
      "admin_pass:${config.sops.secrets."lldap/admin_pass".path}"
      "key_seed:${config.sops.secrets."lldap/key_seed".path}"
    ];
  };

  # Service accounts, which the NixOS module can't declare. Authelia binds as
  # `authelia`, and lldap_password_manager lets it reset users' passwords.
  systemd.services.lldap-bootstrap = {
    description = "Create LLDAP's service accounts";
    after = [ "lldap.service" ];
    requires = [ "lldap.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [
      pkgs.curl
      pkgs.lldap
      pkgs.lldap-cli
    ];
    environment = {
      LLDAP_HTTPURL = "http://127.0.0.1:${toString cfg.http_port}";
      LLDAP_USERNAME = cfg.ldap_user_dn;
      LLDAP_CONFIG = "/dev/null";
    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      DynamicUser = true;
      LoadCredential = [
        "admin_pass:${config.sops.secrets."lldap/admin_pass".path}"
        "authelia_pass:${config.sops.secrets."authelia/ldap_password".path}"
      ];
    };
    script = ''
      LLDAP_PASSWORD=$(< "$CREDENTIALS_DIRECTORY/admin_pass")
      export LLDAP_PASSWORD

      # lldap.service counts as started before its API answers
      for _ in $(seq 30); do
        curl -sf "$LLDAP_HTTPURL/health" > /dev/null && break
        sleep 1
      done
      eval "$(lldap-cli login)"

      if ! lldap-cli user list uid | grep -qx authelia; then
        lldap-cli user add authelia authelia@cleroux.dev -d Authelia
      fi
      if ! lldap-cli user group list authelia | grep -qx lldap_password_manager; then
        lldap-cli user group add authelia lldap_password_manager
      fi
      LLDAP_USER_PASSWORD=$(< "$CREDENTIALS_DIRECTORY/authelia_pass") \
        lldap_set_password -b "$LLDAP_HTTPURL" --token "$LLDAP_TOKEN" -u authelia
    '';
  };

  sops.secrets = {
    "lldap/admin_pass".sopsFile = ./secrets.yaml;
    "lldap/key_seed".sopsFile = ./secrets.yaml;
  };
}
