export FZF_DEFAULT_OPTS="-e -i -d '_' --with-nth 2.. --info=hidden --layout=reverse --scroll-off=5 --tiebreak=index --bind 'home:first,end:last,tab:down,shift-tab:up'"

# The menus are on PATH through the launcher's runtimeInputs
selected="$(printf '%s\n' _applauncher _cliphist _emoji | fzf --prompt='fzf-launcher: ')"
[ -z "$selected" ] && exit

exec "$selected"
