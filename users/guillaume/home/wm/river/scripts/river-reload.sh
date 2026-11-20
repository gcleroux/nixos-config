# Apply the river config to the running session. River has no reload command, but its
# init is a script of riverctl commands, and running a map or rule again replaces it.
# Skipped: the layout generator and uwsm's finalize, which only belong at startup.
# Bindings or rules deleted from the config stay active until river restarts.
# riverctl's "overwrote an existing keybinding" notices go to stdout; errors still show.
grep -v '^rivertile \|uwsm finalize' "${XDG_CONFIG_HOME:-$HOME/.config}/river/init" | bash >/dev/null
