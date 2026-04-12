#!/system/bin/sh
# Smart speaker first-boot defaults.

# Wait for setup wizard to finish
i=0
while [ $i -lt 120 ]; do
    SETUP=$(settings get secure user_setup_complete 2>/dev/null)
    [ "$SETUP" = "1" ] && break
    sleep 2
    i=$((i + 1))
done

CONFIGURED=$(settings get global smart_speaker_configured 2>/dev/null)
[ "$CONFIGURED" = "1" ] && exit 0

sleep 10

settings put global stay_on_while_plugged_in 7
settings put secure lockscreen.disabled 0
settings put global bluetooth_discoverable_timeout 0
cmd role clear-role-holders android.app.role.DIALER 2>/dev/null
cmd role clear-role-holders android.app.role.SMS 2>/dev/null
# Whitelist BT from Doze to prevent track change interruption on screen off
dumpsys deviceidle whitelist +com.android.bluetooth 2>/dev/null

settings put global smart_speaker_configured 1
