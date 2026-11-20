# The notifications dunst kept after they left the screen, newest first
# enter: show again, ctrl-d: delete, ctrl-x: clear all

# fzf calls the script back to reload the list and to preview an entry
case "${1:-}" in
--list)
    dunstctl history | jq -r '.data[0][]
        | [(.id.data | tostring), .appname.data, .summary.data, .body.data]
        | map(gsub("[\t\n]"; " ")) | @tsv'
    exit
    ;;
--show)
    entry=$(dunstctl history | jq -c --argjson id "$2" '.data[0][] | select(.id.data == $id)')
    # dunst only keeps a path for images sent as files or icon names; images sent as
    # raw pixels (most browsers and chat apps) are never written to disk
    image=$(jq -r '.icon_path.data' <<<"$entry")
    if [ -f "$image" ]; then
        # foot draws Sixel; the image takes the top half of the preview
        chafa -f sixels --animate off \
            -s "${FZF_PREVIEW_COLUMNS:-40}x$((${FZF_PREVIEW_LINES:-20} / 2))" "$image"
    fi
    jq -r '"\(.appname.data)\n\n\(.summary.data)\n\n\(.body.data)"' <<<"$entry"
    exit
    ;;
esac

self=$0
"$self" --list | fzf -d $'\t' --with-nth 2.. \
    --header 'enter: show again · ctrl-d: delete · ctrl-x: clear all' \
    --preview "$self --show {1}" --preview-window 'right,40%,wrap' \
    --bind "ctrl-d:execute-silent(dunstctl history-rm {1})+reload($self --list)" \
    --bind "ctrl-x:execute-silent(dunstctl history-clear)+reload($self --list)" \
    --bind "enter:execute-silent([ -n {1} ] && dunstctl history-pop {1})+abort"
