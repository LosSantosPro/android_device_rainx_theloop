#!/system/bin/sh
# Wait for basic init
sleep 5

# Force init state machine forward
setprop ro.crypto.state unencrypted
setprop vold.decrypt trigger_post_fs_data

# Wait for APEXes to load (post-fs-data triggers this)
sleep 15

# Now ADB should be startable
setprop sys.usb.controller 11201000.usb0
setprop vendor.usb.controller 11201000.usb0
setprop sys.usb.configfs 1
setprop sys.usb.config adb

# Wait for adbd to open FFS
sleep 5

# Write UDC
echo "11201000.usb0" > /config/usb_gadget/g1/UDC 2>/dev/null

# Log
dmesg > /mnt/vendor/persist/stage_usb.txt
logcat -d > /mnt/vendor/persist/logcat_usb.txt
