declare -A apps

desktop_file() {
    # Highest priority first: the first entry found for a name wins below
    IFS=: read -ra dirs <<<"${XDG_DATA_HOME:-$HOME/.local/share}:${XDG_DATA_DIRS:-}"
    for dir in "${dirs[@]}"; do
        fd '\.desktop$' "$dir/applications" 2>/dev/null || true
    done
}

while read -r df; do
    app_name=$(awk -F= '/^Name=/ {print $2; exit}' "$df")
    [ -n "$app_name" ] && [ -z "${apps[$app_name]:-}" ] && apps["$app_name"]="$df"
done < <(desktop_file)

export FZF_DEFAULT_OPTS="-e -i --info=hidden --layout=reverse --scroll-off=5 --tiebreak=index --bind 'home:first,end:last'"
selected=$(printf "%s\n" "${!apps[@]}" | sort | fzf -m --prompt="select program(s) to open: ")
[ -z "$selected" ] && exit

while read -r line; do
    setsid dex "${apps[$line]}" >/dev/null 2>&1 &
    disown
    sleep 0.2
done <<<"$selected"
