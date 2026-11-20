# Keyboard layout: EurKEY (US plus accents on right Alt, which the Defy's layers use) or
# Canadian Multilingual. River can't tell waybar which xkb layout is active, so this sets
# one layout at a time, records it and signals the bar. Alt+Space toggles.
state=$XDG_RUNTIME_DIR/kb-layout
options=shift:both_capslock,caps:escape

case ${1:-toggle} in
eu | cms) next=$1 ;;
toggle)
    if [ "$(cat "$state" 2>/dev/null)" = eu ]; then next=cms; else next=eu; fi
    ;;
*)
    echo "usage: kb-layout [eu|cms|toggle]" >&2
    exit 1
    ;;
esac

case $next in
eu) riverctl keyboard-layout -options "$options" eu ;;
cms) riverctl keyboard-layout -variant multix -options "$options" ca ;;
esac

echo "$next" >"$state"
# waybar's custom/kb-layout module rereads the state on this signal
pkill -RTMIN+8 waybar || true
