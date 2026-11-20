# The notifications dunst kept after they left the screen, newest first
# enter: show again, ctrl-o: open a link, ctrl-d: delete, ctrl-x: clear all

entry() {
    dunstctl history | jq -c --argjson id "$1" '.data[0][] | select(.id.data == $id)'
}

# Links dunst found in the text, one per line: a URL, or "[link text] URL" for HTML links
links() {
    entry "$1" | jq -r '.urls.data | select(. != "")'
}

# fzf calls the script back to reload the list, preview an entry and open its links
case "${1:-}" in
--list)
    dunstctl history | jq -r '.data[0][]
        | [(.id.data | tostring), .appname.data, .summary.data, .body.data]
        | map(gsub("[\t\n]"; " ")) | @tsv'
    exit
    ;;
--show)
    entry=$(entry "$2")
    # dunst only keeps a path for images sent as files or icon names; images sent as
    # raw pixels (most browsers and chat apps) are never written to disk
    image=$(jq -r '.icon_path.data' <<<"$entry")
    if [ -f "$image" ]; then
        # foot draws Sixel; the image takes the top half of the preview
        chafa -f sixels --animate off \
            -s "${FZF_PREVIEW_COLUMNS:-40}x$((${FZF_PREVIEW_LINES:-20} / 2))" "$image"
    fi
    jq -r '"\(.appname.data)\n\n\(.summary.data)\n\n\(.body.data)"' <<<"$entry"
    links=$(links "$2")
    if [ -n "$links" ]; then
        printf '\nLinks (ctrl-o):\n%s\n' "$links"
    fi
    exit
    ;;
--open-action)
    # For fzf's transform: open and close the list, or do nothing when there is no link
    if [ -n "$(links "$2")" ]; then
        echo "execute($0 --open $2)+abort"
    fi
    exit
    ;;
--open)
    mapfile -t lines < <(links "$2")
    if [ "${#lines[@]}" -gt 1 ]; then
        line=$(printf '%s\n' "${lines[@]}" | fzf --prompt 'open: ') || exit 0
    else
        line=${lines[0]}
    fi
    # With a token, the browser asks to be activated and river marks its tag urgent
    if token=$(xdg-activation-token); then
        export XDG_ACTIVATION_TOKEN=$token
    fi
    # Detached, so closing the list's terminal doesn't take the browser with it
    setsid -f xdg-open "${line##* }" >/dev/null 2>&1
    exit
    ;;
esac

self=$0
"$self" --list | fzf -d $'\t' --with-nth 2.. \
    --header 'enter: show · ctrl-o: link · ctrl-d: delete · ctrl-x: clear all' \
    --preview "$self --show {1}" --preview-window 'right,40%,wrap' \
    --bind "ctrl-d:execute-silent(dunstctl history-rm {1})+reload($self --list)" \
    --bind "ctrl-x:execute-silent(dunstctl history-clear)+reload($self --list)" \
    --bind "ctrl-o:transform($self --open-action {1})" \
    --bind "enter:execute-silent([ -n {1} ] && dunstctl history-pop {1})+abort"
