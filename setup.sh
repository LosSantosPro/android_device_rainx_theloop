#!/bin/bash
# Post-sync setup for theloop device tree.
# Run once after repo sync to create out-of-tree build files.
# These modules must be outside theloop's soong_namespace for visibility.

DEVICE_DIR="$(cd "$(dirname "$0")" && pwd)"
RAINX_DIR="$(dirname "$DEVICE_DIR")"

# USB audio loopback
mkdir -p "$RAINX_DIR/usb_audio_loopback"
cp "$DEVICE_DIR/usb_audio_loopback/usb_audio_loopback.c" "$RAINX_DIR/usb_audio_loopback/"
cat > "$RAINX_DIR/usb_audio_loopback/Android.bp" << 'EOF'
cc_binary {
    name: "usb_audio_loopback",
    vendor: true,
    srcs: ["usb_audio_loopback.c"],
    shared_libs: [
        "libtinyalsa",
        "libaaudio",
        "liblog",
    ],
}
EOF

# NoCameraStub
cp -r "$DEVICE_DIR/nocamera" "$RAINX_DIR/nocamera"

echo "theloop: setup complete"
