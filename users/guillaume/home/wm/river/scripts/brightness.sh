# Laptop backlight device name
LAPTOP="intel_backlight"

# Brightness step
STEP="5%"

get_brightness() {
    brightnessctl --device "$LAPTOP" -m | cut -d, -f4
}

notify_user() {
    notify-send -t 2000 -h string:x-canonical-private-synchronous:sys-notify \
        -u low -c "overlay" "Brightness: $(get_brightness)"
}

inc_laptop() {
    brightnessctl --device "$LAPTOP" set "$STEP+"
}

dec_laptop() {
    # Dec uses --min-value to prevent laptop screen from going off
    brightnessctl --device "$LAPTOP" --min-value set "$STEP-"
}

# Execute accordingly
case "$1" in
"--inc")
    inc_laptop
    notify_user
    ;;
"--dec")
    dec_laptop
    notify_user
    ;;
esac
