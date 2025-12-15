#!/usr/bin/env nix-shell
#!nix-shell -i bash -p dig qrencode sops wireguard-tools

set -euo pipefail

usage() {
    cat <<'EOF'
Usage:
  wg-peer-add.sh [--output PATH] <peer-name> <peer-address>

Examples:
  wg-peer-add.sh s24-ultra 10.0.9.102
  wg-peer-add.sh --output s24-ultra.conf s24-ultra 10.0.9.102
  wg-peer-add.sh -o s24-ultra.png  s24-ultra 10.0.9.102

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
        OUT_PATH="$2"
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

if [[ $# -ne 2 ]]; then
    usage
    exit 1
fi

PEER_NAME="$1"
PEER_ADDR="$2"

# Gen keys if not already present
if [[ ! -d "./${PEER_NAME}" ]]; then
    mkdir -p "./${PEER_NAME}"

    (
        umask 0077
        wg genkey | sops --encrypt --input-type binary --output-type binary /dev/stdin >"./${PEER_NAME}/private.key"
        wg genpsk | sops --encrypt --input-type binary --output-type binary /dev/stdin >"./${PEER_NAME}/psk.key"
    )

    # Derive public key from the *decrypted* private key (never write plaintext to disk)
    sops -d "./${PEER_NAME}/private.key" | wg pubkey >"./${PEER_NAME}/public.key"
fi

# Build config on stdout (single source of truth)
generate_conf() {
    cat <<EOF
[Interface]
PrivateKey = $(sops -d "./${PEER_NAME}/private.key")
Address = ${PEER_ADDR}/32
DNS = 10.0.9.1

[Peer]
PublicKey = $(cat "./calcifer/public.key")
PresharedKey = $(sops -d "./${PEER_NAME}/psk.key")
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = $(dig whoami.akamai.net +short):51820
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
