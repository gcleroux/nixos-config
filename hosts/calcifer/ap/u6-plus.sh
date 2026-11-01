#!/bin/sh
# OpenWrt "dumb AP" setup for the U6+ behind calcifer. This script is the full
# desired state of the AP: change settings here and re-run it.
#
#   VLAN 1  untagged : LAN SSID + AP management (10.0.0.11)
#   VLAN 20 tagged   : guest SSID, no IP on the AP, AP unreachable from it
#
# calcifer does DHCP/DNS/routing for both networks; the AP only bridges.
# Run with:  ./run.sh [--dry-run] u6-plus.sh [192.168.1.1 on a fresh AP]
# LAN_KEY and GUEST_KEY (Wi-Fi passwords) are provided by run.sh from secrets.yaml.
#
# First install (AP still on 192.168.1.1): reboots and comes back on 10.0.0.11.
# Re-runs: only services whose configuration changed are reloaded.
# DRY_RUN=1: print the pending changes and discard them.
set -e

LAN_SSID="That's what she SSID"
GUEST_SSID="That's What She SSID - Guest"
AP_IP='10.0.0.11'
GATEWAY='10.0.0.1'
GUEST_VLAN='20'
COUNTRY='CA'

# Radios. Channels picked from a scan on 2026-11-01: 2.4 GHz channel 1 was free;
# both non-DFS 80 MHz blocks on 5 GHz (36-48, 149-161) were used by a neighbour,
# so 5 GHz uses 100-112 (DFS: ~1 min radar check after a change, and the AP moves
# on its own if it detects radar). Non-DFS alternative: CHANNEL_5G='36'.
CHANNEL_2G='1'
HTMODE_2G='HE20'
TXPOWER_2G='' # dBm, empty = driver default (maximum allowed)
CHANNEL_5G='100'
HTMODE_5G='HE80'
TXPOWER_5G=''

# Wi-Fi airtime (hostapd limit mode): when both SSIDs are busy, guests get at most
# GUEST/(LAN+GUEST) of the airtime; when the LAN is idle, guests can use all of it.
AIRTIME_LAN_WEIGHT='3'
AIRTIME_GUEST_WEIGHT='1'

die() { echo "ERROR: $*" >&2; exit 1; }

# Only touch uci when a value really changes, so re-runs don't reload anything
# needlessly (uci itself already skips `uci set` with an identical value).
set_opt() { # <config.section.option> <value>; an empty value deletes the option
	if [ -n "$2" ]; then uci set "$1=$2"; else uci -q delete "$1" || true; fi
}
set_list() { # <config.section.option> <value>...
	opt=$1
	shift
	[ "$(uci -q get "$opt")" = "$*" ] && return 0
	uci -q delete "$opt" || true
	for v in "$@"; do uci add_list "$opt=$v"; done
}

# --- preflight -----------------------------------------------------------------
[ -n "${LAN_KEY:-}" ] && [ -n "${GUEST_KEY:-}" ] || die "LAN_KEY/GUEST_KEY not set; run this through run.sh"
for key in "$LAN_KEY" "$GUEST_KEY"; do
	[ ${#key} -ge 8 ] && [ ${#key} -le 63 ] || die "Wi-Fi passwords must be 8-63 characters"
	printf %s "$key" | LC_ALL=C grep -q '[^ -~]' && die "Wi-Fi passwords must be plain ASCII"
done

root_pw=$(awk -F: '$1 == "root" { print $2 }' /etc/shadow)
case "$root_pw" in
	'' | '!' | '*') die "set a root password first (run: passwd)" ;;
esac

[ -z "$(uci changes)" ] || die "the AP has uncommitted uci changes; commit or revert them first"

BR=$(uci -q get network.@device[0].name || true)
PORT=$(uci -q get network.@device[0].ports || true)
[ "$BR" = br-lan ] || die "expected first network device to be br-lan, got '$BR'"
[ -n "$PORT" ] && [ "$(echo "$PORT" | wc -w)" -eq 1 ] || die "expected exactly one port in br-lan, got '$PORT'"

RADIOS=$(uci show wireless | sed -n 's/^wireless\.\([^.=]*\)=wifi-device$/\1/p')
[ -n "$RADIOS" ] || die "no wifi-device sections found"
for r in $RADIOS; do
	uci -q get "wireless.default_$r" >/dev/null || die "missing wireless.default_$r"
done

FIRST_INSTALL=
[ "$(uci -q get network.lan.ipaddr)" = "$AP_IP" ] || FIRST_INSTALL=1

echo "Port: $PORT  Radios: $(echo $RADIOS)${FIRST_INSTALL:+  (first install)}${DRY_RUN:+  (dry run)}"

# reload_config only reacts to changes since its previous run: record the current
# state now, so the final call reloads exactly what this script changed.
[ -n "${DRY_RUN:-}" ] || reload_config

# --- system ----------------------------------------------------------------------
uci set system.@system[0].hostname='u6-plus'
uci set system.@system[0].zonename='America/Toronto'
uci set system.@system[0].timezone='EST5EDT,M3.2.0,M11.1.0'

# --- network: VLAN-aware bridge ------------------------------------------------------
# Named sections (stable across re-runs); drop any others, e.g. anonymous ones
# from older versions of this script.
for s in $(uci -X show network | sed -n 's/^network\.\([^.=]*\)=bridge-vlan$/\1/p'); do
	case "$s" in
		vlan_lan | vlan_guest) ;;
		*) uci delete "network.$s" ;;
	esac
done

uci set network.vlan_lan='bridge-vlan'
uci set network.vlan_lan.device='br-lan'
uci set network.vlan_lan.vlan='1'
set_list network.vlan_lan.ports "$PORT:u*"

uci set network.vlan_guest='bridge-vlan'
uci set network.vlan_guest.device='br-lan'
uci set network.vlan_guest.vlan="$GUEST_VLAN"
set_list network.vlan_guest.ports "$PORT:t"

# Management on VLAN 1 with a static address (calcifer does DHCP for everyone else)
uci set network.lan.device='br-lan.1'
uci set network.lan.proto='static'
uci set network.lan.ipaddr="$AP_IP"
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.gateway="$GATEWAY"
set_list network.lan.dns "$GATEWAY"
uci -q delete network.lan.ip6assign || true

# Guest VLAN: layer 2 only, no address on the AP
uci set network.guest='interface'
uci set network.guest.device="br-lan.$GUEST_VLAN"
uci set network.guest.proto='none'

# --- wireless --------------------------------------------------------------------------
for r in $RADIOS; do
	case "$(uci -q get "wireless.$r.band")" in
		2g) channel=$CHANNEL_2G htmode=$HTMODE_2G txpower=$TXPOWER_2G ;;
		5g) channel=$CHANNEL_5G htmode=$HTMODE_5G txpower=$TXPOWER_5G ;;
		*) die "unexpected band on $r" ;;
	esac
	uci set "wireless.$r.country=$COUNTRY"
	uci set "wireless.$r.channel=$channel"
	uci set "wireless.$r.htmode=$htmode"
	set_opt "wireless.$r.txpower" "$txpower"
	uci set "wireless.$r.airtime_mode=3" # limit mode: only SSIDs with airtime_bss_limit are capped
	uci set "wireless.$r.disabled=0"

	# Same SSID/key as the UniFi config, so existing devices reconnect on their own.
	# OpenWrt 25.12 ships the default wifi-iface sections with disabled=1.
	uci -q delete "wireless.default_$r.disabled" || true
	uci set "wireless.default_$r.ssid=$LAN_SSID"
	uci set "wireless.default_$r.encryption=psk2"
	uci set "wireless.default_$r.key=$LAN_KEY"
	uci set "wireless.default_$r.network=lan"
	uci set "wireless.default_$r.airtime_bss_weight=$AIRTIME_LAN_WEIGHT"

	uci set "wireless.guest_$r=wifi-iface"
	uci set "wireless.guest_$r.device=$r"
	uci set "wireless.guest_$r.mode=ap"
	uci set "wireless.guest_$r.network=guest"
	uci set "wireless.guest_$r.ssid=$GUEST_SSID"
	uci set "wireless.guest_$r.encryption=psk2"
	uci set "wireless.guest_$r.key=$GUEST_KEY"
	uci set "wireless.guest_$r.isolate=1"        # guests can't reach each other on the same radio
	uci set "wireless.guest_$r.bridge_isolate=1" # ...or across radios through the bridge
	uci set "wireless.guest_$r.airtime_bss_weight=$AIRTIME_GUEST_WEIGHT"
	uci set "wireless.guest_$r.airtime_bss_limit=1"
done

# --- firewall: only protects the AP itself (bridged traffic doesn't pass through it) ---
cat > /tmp/firewall.new <<EOF
config defaults
	option input 'ACCEPT'
	option output 'ACCEPT'
	option forward 'REJECT'

config zone
	option name 'lan'
	list device 'br-lan.1'
	option input 'ACCEPT'
	option output 'ACCEPT'
	option forward 'REJECT'

config zone
	option name 'guest'
	list device 'br-lan.$GUEST_VLAN'
	option input 'REJECT'
	option output 'ACCEPT'
	option forward 'REJECT'
EOF
FIREWALL_CHANGED=
[ "$(md5sum < /tmp/firewall.new)" = "$(md5sum < /etc/config/firewall)" ] || FIREWALL_CHANGED=1

# --- dry run: show and discard ----------------------------------------------------------
if [ -n "${DRY_RUN:-}" ]; then
	echo "Pending changes (dry run, nothing applied):"
	uci changes | sed -E "s/(\.key=).*/\1<hidden>/; s/^/  /"
	[ -z "$FIREWALL_CHANGED" ] || echo "  /etc/config/firewall would be replaced"
	[ -n "$(uci changes)" ] || [ -n "$FIREWALL_CHANGED" ] || echo "  (none)"
	for c in system network wireless; do uci revert "$c"; done
	rm -f /tmp/firewall.new
	exit 0
fi

# --- apply ---------------------------------------------------------------------------------
if [ -n "$FIREWALL_CHANGED" ]; then mv /tmp/firewall.new /etc/config/firewall; else rm -f /tmp/firewall.new; fi
uci commit

# calcifer handles DHCP, DNS and IPv6 RAs
/etc/init.d/dnsmasq disable
/etc/init.d/dnsmasq stop >/dev/null 2>&1 || true # complains when already stopped
/etc/init.d/odhcpd disable
/etc/init.d/odhcpd stop >/dev/null 2>&1 || true
/etc/init.d/firewall enable

if [ -n "$FIRST_INSTALL" ]; then
	echo "Done. Rebooting; the AP will come back on $AP_IP (VLAN 1 untagged)."
	reboot
else
	echo "Done. Reloading services whose configuration changed."
	reload_config
fi
