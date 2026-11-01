# Access point (U6+ on OpenWrt)

Dumb AP at `10.0.0.11` (`u6-plus.lan`, switch port 7): it bridges Wi-Fi onto
VLAN 1 (LAN, untagged) and VLAN 20 (guest, tagged); calcifer does the rest.

- `u6-plus.sh`: full desired state of the AP (VLANs, SSIDs, channels, airtime,
  firewall). It overwrites changes made elsewhere.
- `secrets.yaml`: Wi-Fi passwords (sops). Edit with `sops secrets.yaml`.
- `run.sh`: runs a script on the AP with the secrets as shell variables.

```sh
./run.sh --dry-run u6-plus.sh    # show pending changes
./run.sh u6-plus.sh              # apply (only changed services reload)
./run.sh u6-plus.sh 192.168.1.1  # fresh OpenWrt install (reboots)
```

To change the AP, edit `u6-plus.sh`, dry-run, then apply.
