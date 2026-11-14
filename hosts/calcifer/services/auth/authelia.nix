{
  inputs,
  config,
  lib,
  pkgs,
  hostname,
  outputs,
  ...
}:
let
  domain = "home.cleroux.dev";
  stateDir = "/var/lib/authelia-main";
  lldap = config.services.lldap.settings;
in
{
  services.authelia.instances.main = {
    enable = true;
    secrets = {
      jwtSecretFile = config.sops.secrets."authelia/jwt_secret".path;
      storageEncryptionKeyFile = config.sops.secrets."authelia/storage_encryption_key".path;
    };
    environmentVariables = {
      AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = "%d/ldap_password";
      AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = "%d/smtp_password";
    };
    settings = {
      theme = "auto";
      default_2fa_method = "webauthn";
      log.level = "info";

      # Reached by the gateway over the cluster VLAN
      server = {
        address = "tcp://:9091/";
        endpoints.authz.ext-authz.implementation = "ExtAuthz";
      };

      authentication_backend.ldap = {
        implementation = "lldap";
        address = "ldap://${lldap.ldap_host}:${toString lldap.ldap_port}";
        base_dn = lldap.ldap_base_dn;
        user = "uid=authelia,ou=people,${lldap.ldap_base_dn}";
      };

      session = {
        inactivity = "12 hours";
        expiration = "1 week";
        remember_me = "1 month";
        cookies = [
          {
            inherit domain;
            authelia_url = "https://auth.${domain}";
            default_redirection_url = "https://dashboard.${domain}";
          }
        ];
      };

      webauthn = {
        display_name = "Homelab - cleroux.dev";
        enable_passkey_login = true;
        selection_criteria = {
          discoverability = "required";
          user_verification = "required";
        };
        # A passkey checked with fingerprint, face or PIN counts as 2FA
        experimental_enable_passkey_uv_two_factors = true;
        experimental_enable_passkey_upgrade = true;
      };
      totp.issuer = domain;

      storage.local.path = "${stateDir}/db.sqlite3";

      notifier = {
        # Authelia won't start while the mail server is unreachable (e.g. WAN down)
        # Disable these checks so LAN apps can still auth
        disable_startup_check = true;
        smtp = {
          address = "submissions://smtp.migadu.com:465";
          username = "ops@noreply.cleroux.dev";
          sender = "Homelab - cleroux.dev <ops@noreply.cleroux.dev>";
        };
      };

      access_control = {
        default_policy = "deny";
        # First match wins
        rules = [
          {
            domain = "auth.${domain}";
            policy = "bypass";
          }
          # LLDAP has its own login, which only LLDAP admins can pass
          {
            domain = "lldap.${domain}";
            policy = "bypass";
          }
          {
            domain = "dashboard.${domain}";
            policy = "two_factor";
          }
          # Apps not moved behind the login page yet
          {
            domain = "*.${domain}";
            policy = "bypass";
          }
        ];
      };
    };
  };

  systemd.services.authelia-main = {
    # Authelia checks its LDAP login at startup
    after = [ "lldap-bootstrap.service" ];
    wants = [ "lldap-bootstrap.service" ];
    serviceConfig.LoadCredential = [
      "ldap_password:${config.sops.secrets."authelia/ldap_password".path}"
      "smtp_password:${config.sops.secrets."authelia/smtp_password".path}"
    ];
  };

  sops.secrets = {
    "authelia/jwt_secret".sopsFile = ./secrets.yaml;
    "authelia/storage_encryption_key".sopsFile = ./secrets.yaml;
    "authelia/ldap_password".sopsFile = ./secrets.yaml;
    "authelia/smtp_password".sopsFile = ./secrets.yaml;
  };
}
