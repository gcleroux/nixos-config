# "Volume: 0.45 [MUTED]" -> "45% [MUTED]"
get_volume() {
    wpctl get-volume "$1" | awk '{ printf "%d%%", $2 * 100 + 0.5; if ($3) printf " %s", $3 }'
}

# Output Audio
# ============
notify_output_volume() {
    notify-send -t 2000 -h string:x-canonical-private-synchronous:sys-notify \
        -u low -c "overlay" "Output: $(get_volume @DEFAULT_AUDIO_SINK@)"
}

inc_output_volume() {
    wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+ && notify_output_volume
}

dec_output_volume() {
    wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%- && notify_output_volume
}

toggle_output() {
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && notify_output_volume
}

# Input Audio
# ===========
notify_input_volume() {
    notify-send -t 2000 -h string:x-canonical-private-synchronous:sys-notify \
        -u low -c "overlay" "Input: $(get_volume @DEFAULT_AUDIO_SOURCE@)"
}

inc_input_volume() {
    wpctl set-volume -l 1 @DEFAULT_AUDIO_SOURCE@ 2%+ && notify_input_volume
}

dec_input_volume() {
    wpctl set-volume -l 1 @DEFAULT_AUDIO_SOURCE@ 2%- && notify_input_volume
}

toggle_input() {
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && notify_input_volume
}

# Commands Args
# =============
case "$1" in
"--inc-output")
    inc_output_volume
    ;;
"--dec-output")
    dec_output_volume
    ;;
"--toggle-output")
    toggle_output
    ;;
"--inc-input")
    inc_input_volume
    ;;
"--dec-input")
    dec_input_volume
    ;;
"--toggle-input")
    toggle_input
    ;;
esac
