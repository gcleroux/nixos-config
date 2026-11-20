# Prints how many notifications dunst holds in its history, or an empty line when
# there are none, which hides the waybar module. gdbus prints a line for each change
# dunst signals and each time the daemon comes or goes, and each line re-reads it.
gdbus monitor --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications |
  while read -r _; do
    count=$(busctl --user --auto-start=no get-property org.freedesktop.Notifications \
      /org/freedesktop/Notifications org.dunstproject.cmd0 historyLength 2>/dev/null) || count="u 0"
    count=${count#u }
    if [ "$count" -gt 0 ]; then echo "$count"; else echo; fi
  done
