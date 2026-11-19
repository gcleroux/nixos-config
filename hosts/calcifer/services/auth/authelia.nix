{ config, ... }:
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
      oidcHmacSecretFile = config.sops.secrets."authelia/oidc_hmac_secret".path;
      oidcIssuerPrivateKeyFile = config.sops.secrets."authelia/oidc_issuer_private_key".path;
    };
    environmentVariables = {
      AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = "%d/ldap_password";
      AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = "%d/smtp_password";
    };
    settings = {
      theme = "auto";
      default_2fa_method = "webauthn";
      log.level = "info";

      # Every interface: the gateway reaches it over the cluster VLAN, and calcifer's
      # firewall opens this port to it
      server = {
        address = "tcp://:9091/";
        endpoints.authz.ext-authz.implementation = "ExtAuthz";
      };

      authentication_backend.ldap = {
        implementation = "lldap";
        address = "ldap://127.0.0.1:${toString lldap.ldap_port}";
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

      # Login for apps that support OpenID Connect
      identity_providers.oidc.clients = [
        {
          client_id = "vikunja";
          client_name = "Vikunja";
          # Digest of the client secret in flux-apps apps/vikunja/secret.yaml
          client_secret = "$pbkdf2-sha512$310000$aiBGxF2NyrWYaowj.OAOIg$aWXtzI9vFOFF6s3FiXLB/ZJPiYVt0F/.VSa8eOMYgh8sXmYA2QazjeLRTvKZSNYoH35uwBhZ1DQwUN5QHKS5mQ";
          authorization_policy = "two_factor";
          redirect_uris = [ "https://vikunja.${domain}/auth/openid/authelia" ];
          scopes = [
            "openid"
            "profile"
            "email"
          ];
        }
        {
          client_id = "grafana";
          client_name = "Grafana";
          # Digest of the client secret in flux-infra
          # infra/monitoring/controllers/victoria-metrics/grafana-oidc.yaml
          client_secret = "$pbkdf2-sha512$310000$mf7hbUKhXHN4bx8tOfaQ/A$6y01FGqzyyxAVm9o2OoxEXhw72OSS4DSc.4XPm6jiGevUSTf4PtvW1OQWMnPu1JfVap.v9YdOjZ8KQf08RFi9A";
          authorization_policy = "two_factor";
          claims_policy = "grafana";
          require_pkce = true;
          pkce_challenge_method = "S256";
          redirect_uris = [ "https://grafana.${domain}/login/generic_oauth" ];
        }
        {
          client_id = "mealie";
          client_name = "Mealie";
          # Digest of the client secret in flux-apps apps/mealie/oidc-secret.yaml
          client_secret = "$pbkdf2-sha512$310000$6DPlI/8UGQ.1p7fki7pfYQ$tO87YY1MCLJoo.5/d2L5kFLMcRCvOyBoSM2zYBuWV9KUKOgrEZAcJKvYK9SvIl7uNgUMIy5ul1lwOcjtIoIybw";
          authorization_policy = "two_factor";
          require_pkce = true;
          pkce_challenge_method = "S256";
          redirect_uris = [ "https://mealie.${domain}/login" ];
          scopes = [
            "openid"
            "profile"
            "email"
          ];
        }
        {
          client_id = "paperless";
          client_name = "Paperless";
          # Digest of the client secret in flux-apps apps/paperless-ngx/oidc-secret.yaml
          client_secret = "$pbkdf2-sha512$310000$6bHF/fLmqhwAJ52EtRXyMg$pDVZoInpYrido35Jn1JYg7Gp0V3HpyQtXrxlQy8ENXdD8ENBa1Z07rVYBW1Q1dg.Wh93ZO3R7zbi49CqHZcp5w";
          authorization_policy = "two_factor";
          require_pkce = true;
          pkce_challenge_method = "S256";
          redirect_uris = [ "https://paperless.${domain}/accounts/oidc/authelia/login/callback/" ];
          scopes = [
            "openid"
            "profile"
            "email"
          ];
        }
        {
          client_id = "actual";
          client_name = "Actual";
          # Digest of the client secret in flux-apps apps/actual-server/oidc-secret.yaml
          client_secret = "$pbkdf2-sha512$310000$a9UnG1q9G51lg4wbyjfdBg$T3nNBQTFkPaOG7/4H/YCNCJwCDoIYGpcB.bBmJ4Hp62tYuUFKfLD8JfifzaBcBxjV71Wryjd4Sl51qt1JmOO8Q";
          authorization_policy = "two_factor";
          require_pkce = true;
          pkce_challenge_method = "S256";
          redirect_uris = [ "https://actual.${domain}/openid/callback" ];
          scopes = [
            "openid"
            "profile"
            "email"
          ];
        }
        {
          client_id = "audiobookshelf";
          client_name = "Audiobookshelf";
          # Digest of the client secret in Audiobookshelf's own settings (its database)
          client_secret = "$pbkdf2-sha512$310000$k2D7Ek5Cg845WC5esd/7ow$L789rrwGTf3dQlBJCzdFkBdlSoxWAmbDUGFKAL.C166Ld70A3SmnKKmZRYp6TxnSHxDq9wT5lrjgItKZuF3krQ";
          authorization_policy = "two_factor";
          require_pkce = true;
          pkce_challenge_method = "S256";
          redirect_uris = [
            "https://audiobookshelf.${domain}/auth/openid/callback"
            # The phone app's login; Audiobookshelf then hands over to audiobookshelf://oauth
            "https://audiobookshelf.${domain}/auth/openid/mobile-redirect"
          ];
          scopes = [
            "openid"
            "profile"
            "email"
          ];
        }
      ];
      identity_providers.oidc.claims_policies.grafana.id_token = [
        "email"
        "name"
        "groups"
        "preferred_username"
      ];
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
    "authelia/oidc_hmac_secret".sopsFile = ./secrets.yaml;
    "authelia/oidc_issuer_private_key".sopsFile = ./secrets.yaml;
  };
}
