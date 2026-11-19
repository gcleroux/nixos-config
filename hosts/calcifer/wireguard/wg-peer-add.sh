#!/usr/bin/env nix-shell
#!nix-shell -i bash -p qrencode sops wireguard-tools

set -euo pipefail

usage() {
    cat <<'EOF'
Usage:
  wg-peer-add.sh [--output PATH] <peer-name>

The peer must be listed in vpnPeers in hosts/inventory.nix, which assigns its addresses.

Examples:
  wg-peer-add.sh s24-ultra
  wg-peer-add.sh --output s24-ultra.conf s24-ultra
  wg-peer-add.sh -o s24-ultra.png s24-ultra

Behavior:
  - default: print QR code to terminal (ansiutf8)
  - --output *.png : write QR code PNG
  - --output other : write WireGuard config file
EOF
}

OUT_PATH=""

# Parse flags
while [[ $# -gt 0 ]]; do
    case "$1" in
    -o | --output)
        [[ $# -ge 2 ]] || {
            echo "Error: --output requires a path"
            usage
            exit 2
        }
        OUT_PATH=$(realpath -m "$2")
        shift 2
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    --)
        shift
        break
        ;;
    -*)
        echo "Error: unknown option: $1"
        usage
        exit 2
        ;;
    *)
        break
        ;;
    esac
done

if [[ $# -ne 1 ]]; then
    usage
    exit 1
fi

PEER_NAME="$1"

# Keys live next to this script, addresses come from the inventory
cd "$(dirname "$0")"
inventory() { nix eval --raw -f ../../inventory.nix "$1"; }
PEER_ADDR=$(inventory "vpnPeers.${PEER_NAME}.ipv4") || {
    echo "Error: add ${PEER_NAME} to vpnPeers in hosts/inventory.nix first"
    exit 1
}
PEER_ADDR6=$(inventory "vpnPeers.${PEER_NAME}.ipv6")
DNS_ADDR=$(inventory "hosts.calcifer.vpn4")

# Gen keys if not already present
if [[ ! -d "./${PEER_NAME}" ]]; then
    mkdir -p "./${PEER_NAME}"

    # --filename-override picks the .sops.yaml rule by destination path, since
    # sops would otherwise match /dev/stdin against the rules
    (
        umask 0077
        wg genkey | sops --encrypt --filename-override "./${PEER_NAME}/private.key" --input-type binary --output-type binary /dev/stdin >"./${PEER_NAME}/private.key"
        wg genpsk | sops --encrypt --filename-override "./${PEER_NAME}/psk.key" --input-type binary --output-type binary /dev/stdin >"./${PEER_NAME}/psk.key"
    )

    # Derive public key from the *decrypted* private key (never write plaintext to disk)
    sops -d "./${PEER_NAME}/private.key" | wg pubkey >"./${PEER_NAME}/public.key"
fi

# Build config on stdout (single source of truth)
generate_conf() {
    cat <<EOF
[Interface]
PrivateKey = $(sops -d "./${PEER_NAME}/private.key")
Address = ${PEER_ADDR}/32, ${PEER_ADDR6}/128
DNS = ${DNS_ADDR}

[Peer]
PublicKey = $(cat "./calcifer/public.key")
PresharedKey = $(sops -d "./${PEER_NAME}/psk.key")
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = vpn.cleroux.dev:51820
PersistentKeepalive = 25
EOF
}

# Output selection
if [[ -z "$OUT_PATH" ]]; then
    # Default: terminal QR
    qrencode -t ansiutf8 < <(generate_conf)
elif [[ "$OUT_PATH" == *.png ]]; then
    # PNG QR file
    qrencode -t png -o "$OUT_PATH" < <(generate_conf)
    echo "Wrote QR PNG: $OUT_PATH"
else
    # Plain config file
    umask 0077
    generate_conf >"$OUT_PATH"
    echo "Wrote config: $OUT_PATH"
fi
