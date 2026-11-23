# Users with a login on a host. A user is defined once in users/<name>/,
# and each host picks who lives on it with host.users.<name>.
{
  config,
  lib,
  ...
}:
let
  cfg = config.host.users;
  account = name: import ./${name}/account.nix;
  # sops file holding the user's `hashed-password` (from mkpasswd), readable by every host they live on
  passwordFile = name: ./${name}/password.yaml;
  hasPassword = name: builtins.pathExists (passwordFile name);
  # home-manager: users/<name>/home/default.nix always, plus home/<profile>.nix per profile
  profileFile = name: profile: ./${name}/home/${profile}.nix;
  homeUsers = lib.filterAttrs (name: _: builtins.pathExists ./${name}/home) cfg;
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
          profiles = lib.mkOption {
            type = with lib.types; listOf str;
            default = [ ];
            example = [
              "dev"
              "desktop"
            ];
            description = "home-manager profiles for this user on this host, from users/<name>/home/<profile>.nix.";
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

    home-manager.users = lib.mapAttrs (name: user: {
      # A missing profile is reported by the assertion below rather than an import error
      imports = [
        ./${name}/home
      ]
      ++ map (profileFile name) (lib.filter (p: builtins.pathExists (profileFile name p)) user.profiles);
      home.stateVersion = config.system.stateVersion;
    }) homeUsers;

    # At boot there's no session bus yet, so the activation's dconf step runs on a throwaway one.
    # GIO would start gvfs there, which mounts ~/.gvfs and dies with that bus, leaving a dead mount
    # that breaks file managers in ~.
    systemd.services = lib.mapAttrs' (
      name: _: lib.nameValuePair "home-manager-${name}" { environment.GIO_USE_VFS = "local"; }
    ) homeUsers;

    assertions =
      # Without a password, an admin couldn't use sudo
      lib.mapAttrsToList (name: user: {
        assertion = !user.admin || hasPassword name;
        message = "host.users.${name}.admin needs a password: create users/${name}/password.yaml with a `hashed-password` key.";
      }) cfg
      ++ lib.concatLists (
        lib.mapAttrsToList (
          name: user:
          map (profile: {
            assertion = builtins.pathExists (profileFile name profile);
            message = "host.users.${name}.profiles: users/${name}/home/${profile}.nix doesn't exist.";
          }) user.profiles
        ) homeUsers
      );
  };
}
