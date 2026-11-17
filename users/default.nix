# Users with a login on a host. A user is defined once in users/<name>/,
# and each host picks who lives on it with host.users.<name>.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.host.users;
  account = name: import ./${name}/account.nix;
  # sops file holding the user's `hashed-password` (from mkpasswd), readable by every host they live on
  passwordFile = name: ./${name}/password.yaml;
  hasPassword = name: builtins.pathExists (passwordFile name);
in
{
  options.host.users = lib.mkOption {
    default = { };
    description = "Users from users/<name>/ that have an account on this host.";
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          admin = lib.mkEnableOption "sudo (wheel) for this user";
          extraGroups = lib.mkOption {
            type = with lib.types; listOf str;
            default = [ ];
            description = "Groups for this user on this host, on top of wheel.";
          };
        };
      }
    );
  };

  config = {
    # Passwords come only from users/<name>/password.yaml, the same on every host;
    # changes made with `passwd` are reset on the next deploy.
    users.mutableUsers = false;

    users.users = lib.mapAttrs (
      name: user:
      let
        a = account name;
      in
      {
        isNormalUser = true;
        inherit (a) uid;
        shell = pkgs.${a.shell};
        extraGroups = lib.optional user.admin "wheel" ++ user.extraGroups;
        openssh.authorizedKeys.keys = a.sshKeys;
      }
      // lib.optionalAttrs (hasPassword name) {
        hashedPasswordFile = config.sops.secrets."${name}-password".path;
      }
    ) cfg;

    sops.secrets = lib.mapAttrs' (
      name: _:
      lib.nameValuePair "${name}-password" {
        sopsFile = passwordFile name;
        key = "hashed-password";
        # Decrypted before users are created
        neededForUsers = true;
      }
    ) (lib.filterAttrs (name: _: hasPassword name) cfg);

    # Without a password, an admin couldn't use sudo
    assertions = lib.mapAttrsToList (name: user: {
      assertion = !user.admin || hasPassword name;
      message = "host.users.${name}.admin needs a password: create users/${name}/password.yaml with a `hashed-password` key.";
    }) cfg;

    # A login shell has to be enabled system-wide
    programs.zsh.enable = lib.mkIf (lib.any (name: (account name).shell == "zsh") (
      lib.attrNames cfg
    )) true;
  };
}
