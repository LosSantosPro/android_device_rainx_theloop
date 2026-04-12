#!/system/bin/sh
# First-boot only - things that can't be set via SettingsProvider overlay

FLAG=/data/local/tmp/.smart_speaker_configured
[ -f "$FLAG" ] && exit 0

# Wait for BT address (BT service starts after boot_completed)
BTMAC=""
for i in $(seq 1 30); do
    BTMAC=$(settings get secure bluetooth_address 2>/dev/null)
    [ -n "$BTMAC" ] && [ "$BTMAC" != "null" ] && break
    BTMAC=""
    sleep 3
done

# Clear default dialer/SMS roles so users can disable these apps
cmd role clear-role-holders android.app.role.DIALER 2>/dev/null
cmd role clear-role-holders android.app.role.SMS 2>/dev/null

# BT name: "theloop-XXXX" using last 4 of BT MAC
if [ -n "$BTMAC" ]; then
    SUFFIX=$(echo "$BTMAC" | tr -d ':' | tail -c 5)
    settings put secure bluetooth_name "theloop-$SUFFIX"
    touch "$FLAG"
fi
