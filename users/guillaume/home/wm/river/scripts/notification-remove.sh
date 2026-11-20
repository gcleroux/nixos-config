# Hide the top notification and drop it from the list too.
# dunst can only close it into the list, so remove whatever entry the close added.

newest() {
    dunstctl history | jq '.data[0][0].id.data // empty'
}

before=$(newest)
dunstctl close
after=$(newest)

if [ -n "$after" ] && [ "$after" != "$before" ]; then
    dunstctl history-rm "$after"
fi
