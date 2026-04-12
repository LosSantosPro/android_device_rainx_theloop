#!/bin/bash
# Post-sync setup for theloop device tree.
# Run once after repo sync to create out-of-tree build files.

DEVICE_DIR="$(cd "$(dirname "$0")" && pwd)"
RAINX_DIR="$(dirname "$DEVICE_DIR")"

# USB audio loopback build file (must be outside soong_namespace)
mkdir -p "$RAINX_DIR/usb_audio_loopback"
cat > "$RAINX_DIR/usb_audio_loopback/Android.bp" << 'EOF'
cc_binary {
    name: "usb_audio_loopback",
    vendor: true,
    srcs: ["../theloop/usb_audio_loopback/usb_audio_loopback.c"],
    shared_libs: [
        "libtinyalsa",
        "libaaudio",
        "liblog",
    ],
}
EOF

echo "theloop: setup complete"
