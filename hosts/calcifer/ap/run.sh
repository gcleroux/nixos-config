#!/usr/bin/env bash
# Run an AP configuration script on the U6+ with the secrets from secrets.yaml.
#
#   ./run.sh [--dry-run] <script.sh> [host]     host defaults to 10.0.0.11
#
# Each key in secrets.yaml (sops) becomes a shell variable of the same name,
# prepended to the script and sent over SSH stdin, so secrets never appear
# on a command line or on disk in plain text. --dry-run sets DRY_RUN=1 for
# scripts that support it (show pending changes without applying them).
set -euo pipefail

dry_run=
if [ "${1:-}" = --dry-run ]; then
	dry_run=1
	shift
fi

dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
script=${1:?usage: $0 [--dry-run] <script.sh> [host]}
host=${2:-10.0.0.11}

[ -f "$script" ] || { echo "no such script: $script" >&2; exit 1; }

# Decrypt first so a sops failure stops us before anything reaches the AP
vars=$(sops decrypt --output-type json "$dir/secrets.yaml" | jq -r 'to_entries[] | "\(.key)=\(.value | @sh)"')

{
	printf '%s\n' "$vars"
	[ -z "$dry_run" ] || echo 'DRY_RUN=1'
	cat "$script"
} | ssh "root@$host" 'sh -s'
