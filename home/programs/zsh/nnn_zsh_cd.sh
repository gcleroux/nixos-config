# Works as an alias inside .zshrc
n() {
	# Block nesting of nnn in subshells
	[ "${NNNLVL:-0}" -eq 0 ] || {
		echo "nnn is already running"
		return
	}

	# Manual cd on quit with ^G. Add "export" for automatic cd on quit
	NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

	# This allows to alias nnn to n without infinite recursion
	command nnn "-deo$@"

	[ ! -f "$NNN_TMPFILE" ] || {
		. "$NNN_TMPFILE"
		rm -f "$NNN_TMPFILE" >/dev/null
	}
}
