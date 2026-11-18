# nixos-config

NixOS flake for my homelab and laptop, deployed with deploy-rs.

| Host              | Role                     |
| ----------------- | ------------------------ |
| `nixos-fw`        | Framework laptop (river) |
| `calcifer`        | Router                   |
| `totoro`          | NAS                      |
| `nixos-worker-01` | k3s node                 |

## Layout

```
flake.nix                      hosts table, checks, formatter
hosts/_common/                 every host
hosts/inventory.nix            shared subnets and addresses
hosts/<host>/                  one machine
modules/nixos/services/        host.services.<x>, shared by 2+ hosts
users/<name>/                  account.nix, password.yaml
users/<name>/home/             home-manager: default.nix + <profile>.nix
users/<name>/home/programs/    one folder per program
overlays/                      package patches
```

## Commands

```sh
nix develop              # deploy, sops, age, ssh-to-age
nix fmt
nix flake check          # lint, format, build every host
deploy .#<host>
deploy .#<host> --boot
```

## Add a host

1. `flake.nix`: add `<name> = { };` to `hosts`.
2. `hosts/<name>/`: `default.nix`, `hardware.nix`, `disks.nix`, `interfaces.nix`.
3. `hosts/inventory.nix`: its addresses.
4. `host.services.root-deploy.enable = true;`
5. Install: `nix run github:nix-community/nixos-anywhere -- --flake .#<name> root@<ip>`
6. Secrets: add `ssh-keyscan -t ed25519 <name> | ssh-to-age` to `.sops.yaml`, then `sops updatekeys <file>`.

## Add a user

1. `users/<name>/account.nix`: `{ uid = 1001; sshKeys = [ "…" ]; }`, same uid on every host.
2. Admins: `users/<name>/password.yaml` (sops, key `hashed-password` from `mkpasswd -m yescrypt`) and a `.sops.yaml` rule.
3. Optional: `users/<name>/home/default.nix` and `<profile>.nix`.
4. Per host: `host.users.<name> = { admin = true; profiles = [ "dev" ]; };`
