# Works as an alias inside .zshrc
# Using `n` will enable cd on quit, using `nnn` will not
n() {
    # Block nesting of nnn in subshells
    [ "${NNNLVL:-0}" -eq 0 ] || {
        echo "nnn is already running"
        return
    }

    # Automatic cd on quit. Remove "export" for cd on quit only with ^G
    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    command nnn "-de$@"

    [ ! -f "$NNN_TMPFILE" ] || {
        . "$NNN_TMPFILE"
        rm -f "$NNN_TMPFILE" >/dev/null
    }
}
