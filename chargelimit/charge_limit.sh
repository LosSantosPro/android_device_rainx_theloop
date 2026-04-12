#!/vendor/bin/sh
# Battery charge limiter for theloop smart speaker.
# Monitors battery level and stops charging when it reaches the
# configured limit. Resumes charging when level drops 5% below limit.
# Controlled by persist.vendor.charge_limit (0 = disabled, 1-100 = limit%).

CHARGER="/sys/class/power_supply/mtk-master-charger/input_current_limit"
CAPACITY="/sys/class/power_supply/battery/capacity"
PROP="persist.vendor.charge_limit"
HYSTERESIS=5

while true; do
    limit=$(getprop "$PROP")
    if [ -z "$limit" ] || [ "$limit" = "0" ]; then
        # Disabled; ensure charging is enabled and sleep longer
        echo 500000 > "$CHARGER" 2>/dev/null
        sleep 60
        continue
    fi

    level=$(cat "$CAPACITY" 2>/dev/null)
    resume=$((limit - HYSTERESIS))

    if [ "$level" -ge "$limit" ]; then
        echo 0 > "$CHARGER" 2>/dev/null
    elif [ "$level" -le "$resume" ]; then
        echo 500000 > "$CHARGER" 2>/dev/null
    fi

    sleep 30
done
