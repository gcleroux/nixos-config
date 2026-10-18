# Kubernetes PKI on nixos-worker-01

The cluster no longer uses `services.kubernetes.easyCerts` (the cfssl + certmgr runtime
PKI of the NixOS module). Certificates are issued by `pkgs/kube-pki` from a CA that
lives in this repository, following the spec that the `host.services.kubernetes-pki`
module (`modules/nixos/services/kubernetes-pki.nix`) derives from the kubernetes
configuration. The host only enables the module and points it at its CA material
(`hosts/nixos-worker-01/kubernetes-pki.nix`).

## What lives where

| Material | Location | Lifetime |
|---|---|---|
| CA certificate | `hosts/nixos-worker-01/pki/ca.pem` (plain text) | 10 years |
| CA private key | `hosts/nixos-worker-01/pki/ca-key.pem` (sops) | with the CA |
| service-account signing key | `hosts/nixos-worker-01/pki/service-account-key.pem` (sops) | never rotated casually |
| admin kubeconfig for workstations | `hosts/nixos-worker-01/pki/admin.kubeconfig` (sops) | 5 years |
| component certificates | `/var/lib/kubernetes/secrets/*.pem` on the host | 365 days, renewed 30 days before expiry |
| cluster-admin kubeconfig on the host | `/etc/kubernetes/cluster-admin.kubeconfig` (root) | follows the component certificate |
| the spec the host enforces | `/etc/kubernetes/kube-pki-spec.json` | generated from Nix |

Component certificates are (re)issued by `kubernetes-pki.service` before the kubernetes
units start, again whenever `nixos-rebuild switch` changes the spec, and daily by
`kubernetes-pki-renew.timer`. Whatever uses a re-issued file is restarted.

## One-time bootstrap

1. Let the host decrypt its secrets: get its age key and add it to `.sops.yaml`
   (the commented `nixos_worker_01` lines):

   ```sh
   ssh-keyscan -t ed25519 nixos-worker-01 2>/dev/null | ssh-to-age
   ```

2. Create the CA material. To keep the current cluster identity (existing tokens and
   kubeconfigs stay valid), import what easyCerts generated:

   ```sh
   mkdir -p /tmp/kube-import
   ssh nixos-worker-01 sudo cat /var/lib/cfssl/ca.pem > /tmp/kube-import/ca.pem
   ssh nixos-worker-01 sudo cat /var/lib/cfssl/ca-key.pem > /tmp/kube-import/ca-key.pem
   ssh nixos-worker-01 sudo cat /var/lib/kubernetes/secrets/service-account-key.pem > /tmp/kube-import/service-account-key.pem
   nix run .#kube-pki -- init-ca --out /tmp/kube-pki --import /tmp/kube-import \
     --server https://nixos-worker-01:6443
   ```

   For a brand new identity drop `--import`. Every service-account token is then
   re-signed, so expect to restart pods once after the switch.

3. Put the files in the repository and encrypt the private ones in place:

   ```sh
   cp /tmp/kube-pki/ca.pem hosts/nixos-worker-01/pki/
   for f in ca-key.pem service-account-key.pem admin.kubeconfig; do
     cp /tmp/kube-pki/$f hosts/nixos-worker-01/pki/$f
     sops -e -i hosts/nixos-worker-01/pki/$f
   done
   rm -rf /tmp/kube-pki /tmp/kube-import
   git add hosts/nixos-worker-01/pki
   ```

4. Deploy with `nixos-rebuild switch --flake .#nixos-worker-01`. certmgr and cfssl go
   away, `kubernetes-pki.service` issues the certificates and restarts the units that
   use them. Check with:

   ```sh
   sudo kube-pki status
   systemctl status kubernetes-pki.service kubernetes-pki-renew.timer
   sudo kubectl --kubeconfig /etc/kubernetes/cluster-admin.kubeconfig get nodes
   ```

5. Once everything is healthy, `sudo rm -rf /var/lib/cfssl` on the host.

## Workstation access

```sh
sops -d hosts/nixos-worker-01/pki/admin.kubeconfig > ~/.kube/Configs/homelab.yaml
chmod 600 ~/.kube/Configs/homelab.yaml
```

It embeds the CA and a `system:masters` client certificate valid for five years. To
mint a new one, decrypt `ca.pem`, `ca-key.pem` and `service-account-key.pem` into a
directory and run `init-ca --out <that directory> --server ...`: an existing CA and
signing key in the output directory are kept, only the admin credential is re-created.

## Changing and rotating things

- **SANs, names, lifetimes**: set `host.services.kubernetes-pki.certs.<name>.*`,
  `validityDays` or `renewBeforeDays`; the next switch re-issues only the certificates
  that differ. Extra certificates signed by the cluster CA go into `certs` too.
- **CA rotation** (every 10 years, or after a compromise): run `init-ca` without
  `--import` into an empty directory, replace the files in `pki/`, switch. All component
  certificates are re-issued, the admin kubeconfig changes, and pods need a restart for
  new service-account tokens.
- **Service-account key**: keep it. Changing it invalidates every token in the cluster.

## Troubleshooting

```sh
journalctl -u kubernetes-pki -u kubernetes-pki-renew
sudo kube-pki status                      # what ensure would do, and why
sudo kube-pki ensure --no-restart         # issue without restarting anything
openssl x509 -noout -text -in /var/lib/kubernetes/secrets/kube-apiserver.pem
```
