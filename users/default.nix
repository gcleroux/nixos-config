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
    ) cfg;

    # A login shell has to be enabled system-wide
    programs.zsh.enable = lib.mkIf (lib.any (name: (account name).shell == "zsh") (
      lib.attrNames cfg
    )) true;
  };
}
